package me.openroot.unixservice;

import java.io.*;
import java.net.*;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.logging.*;
import org.json.*;

/**
 * Unix-specific implementation of the rootd service.
 * This service provides root emulation capabilities through Unix domain sockets.
 */
public class UnixRootdService {
    private static final String SOCKET_PATH = "/tmp/rootd.sock";
    private static final String CONFIG_PATH = "/etc/rootd/config.json";
    private static final Logger logger = Logger.getLogger(UnixRootdService.class.getName());
    
    private final ExecutorService executorService;
    private volatile boolean isRunning;
    private Path socketPath;
    private JSONObject config;

    public UnixRootdService() {
        executorService = Executors.newCachedThreadPool();
        socketPath = Paths.get(SOCKET_PATH);
        loadConfig();
    }

    private void loadConfig() {
        try {
            String configContent = new String(Files.readAllBytes(Paths.get(CONFIG_PATH)));
            config = new JSONObject(configContent);
            logger.info("Configuration loaded successfully");
        } catch (IOException e) {
            logger.warning("Could not load config, using defaults: " + e.getMessage());
            config = new JSONObject();
        }
    }

    public void start() {
        isRunning = true;
        try {
            // Delete existing socket file if it exists
            Files.deleteIfExists(socketPath);

            // Create Unix domain socket
            UnixDomainSocketAddress address = UnixDomainSocketAddress.of(socketPath);
            try (ServerSocket serverSocket = ServerSocket.class
                    .getDeclaredConstructor(ProtocolFamily.class)
                    .newInstance(StandardProtocolFamily.UNIX)) {
                
                serverSocket.bind(address);
                logger.info("UnixRootdService started on " + SOCKET_PATH);

                while (isRunning) {
                    final Socket clientSocket = serverSocket.accept();
                    executorService.submit(() -> handleClient(clientSocket));
                }
            }
        } catch (Exception e) {
            logger.severe("Failed to start service: " + e.getMessage());
            throw new RuntimeException("Service startup failed", e);
        }
    }

    private void handleClient(Socket clientSocket) {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
             PrintWriter writer = new PrintWriter(clientSocket.getOutputStream(), true)) {
            
            String request = reader.readLine();
            if (request != null) {
                JSONObject response = processRequest(new JSONObject(request));
                writer.println(response.toString());
            }
        } catch (Exception e) {
            logger.warning("Error handling client: " + e.getMessage());
        }
    }

    private JSONObject processRequest(JSONObject request) {
        JSONObject response = new JSONObject();
        try {
            String operation = request.getString("operation");
            JSONObject params = request.optJSONObject("params");

            switch (operation.toUpperCase()) {
                case "CHECK_ROOT":
                    response.put("success", checkRoot());
                    break;
                    
                case "FILE_ACCESS":
                    if (params != null) {
                        String path = params.getString("path");
                        String mode = params.getString("mode");
                        response.put("success", checkFileAccess(path, mode));
                    }
                    break;
                    
                case "EXECUTE_COMMAND":
                    if (params != null) {
                        String command = params.getString("command");
                        response.put("result", executeCommand(command));
                    }
                    break;
                    
                case "GET_CAPABILITIES":
                    response.put("capabilities", getCapabilities());
                    break;
                    
                default:
                    response.put("error", "Unknown operation: " + operation);
                    response.put("success", false);
            }
        } catch (Exception e) {
            response.put("error", e.getMessage());
            response.put("success", false);
        }
        return response;
    }

    private boolean checkRoot() {
        // Check if running as root using Unix-specific call
        try {
            Process process = new ProcessBuilder("id", "-u").start();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String uid = reader.readLine();
                return "0".equals(uid);
            }
        } catch (IOException e) {
            logger.warning("Failed to check root status: " + e.getMessage());
            return false;
        }
    }

    private boolean checkFileAccess(String path, String mode) {
        Path filePath = Paths.get(path);
        try {
            switch (mode.toUpperCase()) {
                case "READ":
                    return Files.isReadable(filePath);
                case "WRITE":
                    return Files.isWritable(filePath);
                case "EXECUTE":
                    return Files.isExecutable(filePath);
                default:
                    return false;
            }
        } catch (SecurityException e) {
            logger.warning("Security check failed for " + path + ": " + e.getMessage());
            return false;
        }
    }

    private JSONObject executeCommand(String command) {
        JSONObject result = new JSONObject();
        try {
            // Use posix-specific shell
            ProcessBuilder pb = new ProcessBuilder("/bin/sh", "-c", command);
            pb.redirectErrorStream(true);
            Process process = pb.start();

            // Read output
            StringBuilder output = new StringBuilder();
            try (BufferedReader br = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = br.readLine()) != null) {
                    output.append(line).append("\n");
                }
            }

            int exitCode = process.waitFor();
            result.put("exitCode", exitCode);
            result.put("output", output.toString());
            result.put("success", exitCode == 0);
        } catch (Exception e) {
            result.put("success", false);
            result.put("error", e.getMessage());
        }
        return result;
    }

    private JSONObject getCapabilities() {
        JSONObject capabilities = new JSONObject();
        capabilities.put("canRoot", checkRoot());
        capabilities.put("canExecute", true);
        capabilities.put("canAccessFiles", true);
        capabilities.put("configuredPaths", config.optJSONArray("allowed_paths"));
        return capabilities;
    }

    public void stop() {
        isRunning = false;
        executorService.shutdown();
        try {
            if (!executorService.awaitTermination(5, TimeUnit.SECONDS)) {
                executorService.shutdownNow();
            }
            Files.deleteIfExists(socketPath);
        } catch (Exception e) {
            logger.warning("Error during shutdown: " + e.getMessage());
        }
    }

    // Main method for standalone testing
    public static void main(String[] args) {
        UnixRootdService service = new UnixRootdService();
        
        // Setup shutdown hook
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            logger.info("Shutting down UnixRootdService...");
            service.stop();
        }));

        // Start service
        service.start();
    }
}