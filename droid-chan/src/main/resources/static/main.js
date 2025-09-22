// Main JavaScript for the web interface
document.addEventListener('DOMContentLoaded', function() {
    checkRootStatus();
    loadOperations();
});

async function checkRootStatus() {
    try {
        const response = await fetch('/api/status');
        const data = await response.json();
        
        const statusElement = document.getElementById('rootStatus');
        if (data.isRoot) {
            statusElement.textContent = 'Root Access Available';
            statusElement.className = 'status root';
        } else {
            statusElement.textContent = 'Running in Emulation Mode';
            statusElement.className = 'status emulated';
        }
    } catch (error) {
        console.error('Error checking root status:', error);
        document.getElementById('rootStatus').textContent = 'Error checking root status';
    }
}

async function loadOperations() {
    const operations = [
        'File System Operations',
        'Process Management',
        'Network Configuration',
        'Mount Management'
    ];

    const operationsList = document.getElementById('operationsList');
    operations.forEach(op => {
        const li = document.createElement('li');
        li.textContent = op;
        operationsList.appendChild(li);
    });
}

async function executeOperation(operation, params) {
    try {
        const response = await fetch('/api/execute', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                operation,
                params
            })
        });
        return await response.json();
    } catch (error) {
        console.error(`Error executing operation ${operation}:`, error);
        throw error;
    }
}