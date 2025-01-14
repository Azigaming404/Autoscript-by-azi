<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Mendapatkan path dari endpoint
    $path = $_GET['path'] ?? null;
    $username = $_POST['username'] ?? null;
    $password = $_POST['password'] ?? null;
    $masaaktif = $_POST['masaaktif'] ?? null;
    $quota = $_POST['quota'] ?? null;
    $ip = $_POST['ip'] ?? null;

    // Validasi parameter wajib
    if (!$path) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Parameter "path" harus diisi (ssh, vmess, vless, trojan).'
        ]);
        exit;
    }

    if (!$username || !$masaaktif || !$ip) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Parameter (username, masaaktif, ip) harus diisi.'
        ]);
        exit;
    }

    // Validasi parameter tambahan berdasarkan path
    if ($path === 'ssh' && !$password) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Parameter "password" harus diisi untuk path SSH.'
        ]);
        exit;
    }

    if ($path !== 'ssh' && !$quota) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Parameter "quota" harus diisi untuk path selain SSH.'
        ]);
        exit;
    }

    // Routing berdasarkan path
    switch ($path) {
        case 'ssh':
            handleSsh($username, $password, $masaaktif, $ip);
            break;
        case 'vmess':
            handleVmess($username, $masaaktif, $quota, $ip);
            break;
        case 'vless':
            handleVless($username, $masaaktif, $quota, $ip);
            break;
        case 'trojan':
            handleTrojan($username, $masaaktif, $quota, $ip);
            break;
        default:
            echo json_encode([
                'status' => 'error',
                'message' => 'Path tidak valid. Gunakan salah satu: ssh, vmess, vless, trojan.'
            ]);
            exit;
    }
} else {
    // Response jika metode selain POST digunakan
    echo json_encode([
        'status' => 'error',
        'message' => 'Hanya mendukung metode POST.'
    ]);
}

// Fungsi untuk menangani SSH
function handleSsh($username, $password, $masaaktif, $ip) {
    $scriptPath = '/usr/bin/addssh';
    executeSshScript($scriptPath, $username, $password, $masaaktif, $ip);
}

// Fungsi untuk menangani Vmess
function handleVmess($username, $masaaktif, $quota, $ip) {
    $scriptPath = '/usr/bin/vmess';
    executeScript($scriptPath, $username, $masaaktif, $quota, $ip, 'vmess');
}

// Fungsi untuk menangani Vless
function handleVless($username, $masaaktif, $quota, $ip) {
    $scriptPath = '/usr/bin/vless';
    executeScript($scriptPath, $username, $masaaktif, $quota, $ip, 'vless');
}

// Fungsi untuk menangani Trojan
function handleTrojan($username, $masaaktif, $quota, $ip) {
    $scriptPath = '/usr/bin/trojan';
    executeScript($scriptPath, $username, $masaaktif, $quota, $ip, 'trojan');
}

// Fungsi untuk menjalankan skrip SSH
function executeSshScript($scriptPath, $username, $password, $masaaktif, $ip) {
    // Validasi file script
    if (!file_exists($scriptPath)) {
        echo json_encode([
            'status' => 'error',
            'message' => "File skrip $scriptPath tidak ditemukan."
        ]);
        exit;
    }

    if (!is_executable($scriptPath)) {
        echo json_encode([
            'status' => 'error',
            'message' => "Skrip $scriptPath tidak memiliki izin eksekusi."
        ]);
        exit;
    }

    // Jalankan skrip Bash menggunakan shell_exec
    $command = escapeshellcmd("bash $scriptPath $username $password $masaaktif $ip");
    $output = shell_exec($command);

    // Log perintah dan output untuk debugging (opsional)
    error_log("Command: $command");
    error_log("Output: $output");

    // Validasi output dari skrip
    if (empty($output)) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Output skrip kosong. Pastikan skrip SSH bekerja dengan benar.'
        ]);
        exit;
    }

    // Response berhasil
    echo json_encode([
        'status' => 'success',
        'path' => 'ssh',
        'details' => $output
    ]);
}

// Fungsi untuk menjalankan skrip umum (Vmess, Vless, Trojan)
function executeScript($scriptPath, $username, $masaaktif, $quota, $ip, $path) {
    // Validasi file script
    if (!file_exists($scriptPath)) {
        echo json_encode([
            'status' => 'error',
            'message' => "File skrip $scriptPath tidak ditemukan."
        ]);
        exit;
    }

    if (!is_executable($scriptPath)) {
        echo json_encode([
            'status' => 'error',
            'message' => "Skrip $scriptPath tidak memiliki izin eksekusi."
        ]);
        exit;
    }

    // Jalankan skrip Bash menggunakan shell_exec
    $command = escapeshellcmd("bash $scriptPath $username $masaaktif $quota $ip");
    $output = shell_exec($command);

    // Restart Xray setelah eksekusi
    $restartCommand = escapeshellcmd("sudo systemctl restart xray");
    shell_exec($restartCommand);

    // Log perintah dan output untuk debugging (opsional)
    error_log("Command: $command");
    error_log("Output: $output");

    // Regex untuk masing-masing jenis link
    $patterns = [
        'vmess' => '/vmess:\/\/[^\s]+/',
        'vless' => '/vless:\/\/[^\s]+/',
        'trojan' => '/trojan:\/\/[^\s]+/'
    ];

    preg_match_all($patterns[$path], $output, $matches);

    // Validasi apakah ada link ditemukan
    if (!isset($matches[0]) || count($matches[0]) === 0) {
        echo json_encode([
            'status' => 'error',
            'message' => "Tidak ada link $path ditemukan dalam output."
        ]);
        exit;
    }

    // Response berhasil
    echo json_encode([
        'status' => 'success',
        'path' => $path,
        'links' => $matches[0]
    ]);
}
