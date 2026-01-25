// WireGuard Mesh Discovery - Web UI JavaScript

const API_BASE = '/cgi-bin/wg-mesh-discovery';

// DOM Elements
const devicesBody = document.getElementById('devices-body');
const searchInput = document.getElementById('search');
const typeFilter = document.getElementById('type-filter');
const btnScan = document.getElementById('btn-scan');
const btnRefresh = document.getElementById('btn-refresh');
const btnExport = document.getElementById('btn-export');
const modal = document.getElementById('modal');
const modalTitle = document.getElementById('modal-title');
const modalBody = document.getElementById('modal-body');

// State
let devices = [];

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    loadDevices();
    setupEventListeners();
});

function setupEventListeners() {
    btnScan.addEventListener('click', scanDevices);
    btnRefresh.addEventListener('click', loadDevices);
    btnExport.addEventListener('click', exportDevices);
    searchInput.addEventListener('input', filterDevices);
    typeFilter.addEventListener('change', filterDevices);
    document.querySelector('.close').addEventListener('click', closeModal);
    modal.addEventListener('click', (e) => {
        if (e.target === modal) closeModal();
    });
}

async function loadDevices() {
    try {
        devicesBody.innerHTML = '<tr><td colspan="6" class="loading">Loading devices...</td></tr>';

        // Try to fetch from API, fall back to demo data
        try {
            const response = await fetch(`${API_BASE}/list?format=json`);
            devices = await response.json();
        } catch {
            // Demo data for testing
            devices = getDemoData();
        }

        updateStats();
        renderDevices(devices);
    } catch (error) {
        devicesBody.innerHTML = `<tr><td colspan="6" class="loading">Error loading devices: ${error.message}</td></tr>`;
    }
}

async function scanDevices() {
    try {
        btnScan.disabled = true;
        btnScan.textContent = 'Scanning...';

        try {
            await fetch(`${API_BASE}/scan`, { method: 'POST' });
        } catch {
            // Simulate scan delay
            await new Promise(r => setTimeout(r, 2000));
        }

        await loadDevices();
    } finally {
        btnScan.disabled = false;
        btnScan.textContent = 'Scan Now';
    }
}

function filterDevices() {
    const search = searchInput.value.toLowerCase();
    const type = typeFilter.value;

    const filtered = devices.filter(device => {
        const matchesSearch =
            device.ip.toLowerCase().includes(search) ||
            device.mac.toLowerCase().includes(search) ||
            (device.vendor || '').toLowerCase().includes(search) ||
            (device.hostname || '').toLowerCase().includes(search);

        const matchesType = !type || getDeviceType(device.vendor) === type;

        return matchesSearch && matchesType;
    });

    renderDevices(filtered);
}

function renderDevices(deviceList) {
    if (deviceList.length === 0) {
        devicesBody.innerHTML = '<tr><td colspan="6" class="loading">No devices found</td></tr>';
        return;
    }

    devicesBody.innerHTML = deviceList.map(device => {
        const type = getDeviceType(device.vendor);
        const lastSeen = device.timestamp
            ? new Date(device.timestamp * 1000).toLocaleString()
            : 'Unknown';

        return `
            <tr onclick="showDeviceDetails('${device.ip}')" style="cursor: pointer;">
                <td>${device.ip}</td>
                <td>${device.mac}</td>
                <td>${device.vendor || 'Unknown'}</td>
                <td><span class="type-badge type-${type}">${type}</span></td>
                <td>${device.hostname || '-'}</td>
                <td>${lastSeen}</td>
            </tr>
        `;
    }).join('');
}

function updateStats() {
    document.getElementById('total-devices').textContent = devices.length;
    document.getElementById('total-printers').textContent =
        devices.filter(d => getDeviceType(d.vendor) === 'printer').length;
    document.getElementById('total-nas').textContent =
        devices.filter(d => getDeviceType(d.vendor) === 'nas').length;
    document.getElementById('total-other').textContent =
        devices.filter(d => !['printer', 'nas', 'camera'].includes(getDeviceType(d.vendor))).length;
}

function getDeviceType(vendor) {
    if (!vendor) return 'other';
    vendor = vendor.toLowerCase();
    if (/hp|canon|epson|brother|printer/.test(vendor)) return 'printer';
    if (/synology|qnap|nas|netgear.*ready/.test(vendor)) return 'nas';
    if (/hikvision|dahua|axis|camera/.test(vendor)) return 'camera';
    return 'other';
}

function showDeviceDetails(ip) {
    const device = devices.find(d => d.ip === ip);
    if (!device) return;

    modalTitle.textContent = `Device: ${device.ip}`;
    modalBody.innerHTML = `
        <table style="width: 100%;">
            <tr><th style="width: 120px;">IP Address</th><td>${device.ip}</td></tr>
            <tr><th>MAC Address</th><td>${device.mac}</td></tr>
            <tr><th>Vendor</th><td>${device.vendor || 'Unknown'}</td></tr>
            <tr><th>Type</th><td>${getDeviceType(device.vendor)}</td></tr>
            <tr><th>DNS Name</th><td>${device.hostname || '-'}</td></tr>
            <tr><th>Discovery</th><td>${device.method || '-'}</td></tr>
            <tr><th>Last Seen</th><td>${device.timestamp ? new Date(device.timestamp * 1000).toLocaleString() : 'Unknown'}</td></tr>
        </table>
    `;
    modal.classList.remove('hidden');
}

function closeModal() {
    modal.classList.add('hidden');
}

function exportDevices() {
    const csv = [
        'IP,MAC,Vendor,Type,Hostname,LastSeen',
        ...devices.map(d =>
            `${d.ip},${d.mac},"${d.vendor || ''}",${getDeviceType(d.vendor)},${d.hostname || ''},${d.timestamp || ''}`
        )
    ].join('\n');

    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'devices.csv';
    a.click();
    URL.revokeObjectURL(url);
}

function getDemoData() {
    return [
        { ip: '192.168.1.50', mac: 'aa:bb:cc:dd:ee:01', vendor: 'HP Inc.', method: 'arp', timestamp: Date.now()/1000, hostname: 'printer-50.mesh' },
        { ip: '192.168.1.100', mac: 'aa:bb:cc:dd:ee:02', vendor: 'Synology Inc.', method: 'arp', timestamp: Date.now()/1000, hostname: 'nas-100.mesh' },
        { ip: '192.168.1.110', mac: 'aa:bb:cc:dd:ee:03', vendor: 'Hikvision', method: 'nmap', timestamp: Date.now()/1000, hostname: 'camera-110.mesh' },
        { ip: '192.168.1.25', mac: 'aa:bb:cc:dd:ee:04', vendor: 'Apple Inc.', method: 'mdns', timestamp: Date.now()/1000, hostname: 'device-25.mesh' },
    ];
}
