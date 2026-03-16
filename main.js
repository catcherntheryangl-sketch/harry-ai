const { app, BrowserWindow, shell, Menu, Tray, nativeImage } = require('electron');
const path = require('path');

// ── Keep single instance ──────────────────────────────
const gotLock = app.requestSingleInstanceLock();
if (!gotLock) { app.quit(); process.exit(0); }

let mainWindow;
let tray;

function createWindow() {
  mainWindow = new BrowserWindow({
    width:  430,
    height: 900,
    minWidth:  380,
    minHeight: 600,
    title: 'Harry A.I.',
    // No default menu bar
    autoHideMenuBar: true,
    webPreferences: {
      // ✅ This is the key setting — disables web security
      // so ALL API providers work with no CORS issues
      webSecurity: false,
      nodeIntegration: false,
      contextIsolation: true,
    },
    backgroundColor: '#07070C',
    show: false, // show after ready-to-show for smooth launch
    titleBarStyle: 'default',
  });

  // Load the app
  mainWindow.loadFile('index.html');

  // Show when ready (prevents white flash)
  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
    mainWindow.focus();
  });

  // Open external links in browser, not in app
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  mainWindow.on('closed', () => { mainWindow = null; });
}

// ── App lifecycle ─────────────────────────────────────
app.whenReady().then(() => {
  // Remove default menu entirely
  Menu.setApplicationMenu(null);
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

// Focus existing window if user tries to open a second instance
app.on('second-instance', () => {
  if (mainWindow) {
    if (mainWindow.isMinimized()) mainWindow.restore();
    mainWindow.focus();
  }
});
