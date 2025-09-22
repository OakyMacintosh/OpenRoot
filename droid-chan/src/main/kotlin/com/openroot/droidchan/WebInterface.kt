package com.openroot.droidchan

import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.server.html.*
import kotlinx.html.*

class WebInterface {
    private val server = embeddedServer(Netty, port = 8080) {
        routing {
            get("/") {
                call.respondHtml {
                    head {
                        title("Droid-Chan Web Interface")
                        styleLink("/static/styles.css")
                    }
                    body {
                        div("container") {
                            h1 { +"Droid-Chan Root Management" }
                            div("status-panel") {
                                h2 { +"Root Status" }
                                div("status") {
                                    id = "rootStatus"
                                    +"Checking..."
                                }
                            }
                            div("operations") {
                                h2 { +"Available Operations" }
                                ul {
                                    id = "operationsList"
                                }
                            }
                        }
                        script(src = "/static/main.js") {}
                    }
                }
            }

            // API endpoints
            get("/api/status") {
                val status = RootdClient().checkRoot()
                call.respondText { """{"isRoot": $status}""" }
            }
        }
    }

    fun start() {
        server.start(wait = false)
    }

    fun stop() {
        server.stop(1000, 2000)
    }
}