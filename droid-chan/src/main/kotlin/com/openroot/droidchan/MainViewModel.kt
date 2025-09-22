package com.openroot.droidchan

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch

class MainViewModel : ViewModel() {
    private val rootdClient = RootdClient()
    var uiState by mutableStateOf(UiState())
        private set

    fun checkRootStatus() {
        viewModelScope.launch {
            try {
                val isRoot = rootdClient.checkRoot()
                uiState = uiState.copy(
                    isRoot = isRoot,
                    status = if (isRoot) "Root access available" else "Running in emulation mode"
                )
            } catch (e: Exception) {
                uiState = uiState.copy(status = "Error: ${e.message}")
            }
        }
    }

    data class UiState(
        val isRoot: Boolean = false,
        val status: String = "Checking root status...",
        val operations: List<String> = emptyList()
    )
}