// System monitoring
function updateSystemStats() {
    const cpu = Math.random() * 100;
    const ram = Math.random() * 100;
    const disk = Math.random() * 100;

    document.getElementById('cpu-bar').style.width = cpu + '%';
    document.getElementById('ram-bar').style.width = ram + '%';
    document.getElementById('disk-bar').style.width = disk + '%';

    document.getElementById('cpu-val').textContent = cpu.toFixed(1) + '%';
    document.getElementById('ram-val').textContent = ram.toFixed(1) + '%';
    document.getElementById('disk-val').textContent = disk.toFixed(1) + '%';
}

setInterval(updateSystemStats, 2000);
updateSystemStats();

// Terminal
const terminalOutput = document.getElementById('terminal-output');
const cmdInput = document.getElementById('cmd-input');

const commands = {
    help: 'Available commands: help, clear, status, neofetch, hack, matrix',
    clear: () => { terminalOutput.innerHTML = ''; return ''; },
    status: 'System: OPERATIONAL | Threat Level: MINIMAL | Neural Link: ACTIVE',
    neofetch: `
    ██████╗ ██╗      █████╗ ███████╗███████╗
    ██╔══██╗██║     ██╔══██╗╚══███╔╝██╔════╝
    ██████╔╝██║     ███████║  ███╔╝ █████╗  
    ██╔══██╗██║     ██╔══██║ ███╔╝  ██╔══╝  
    ██████╔╝███████╗██║  ██║███████╗███████╗
    ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝
    OS: BlazeNeuro Linux | Kernel: 6.7.4`,
    hack: 'Initiating neural hack... ACCESS GRANTED ✓',
    matrix: 'Wake up, Neo... The Matrix has you...'
};

cmdInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        const cmd = cmdInput.value.trim();
        if (cmd) {
            const output = commands[cmd] || `Command not found: ${cmd}`;
            const result = typeof output === 'function' ? output() : output;
            if (result) {
                terminalOutput.innerHTML += `<div><span style="color:#0ff">root@blazeneuro:~$</span> ${cmd}</div>`;
                terminalOutput.innerHTML += `<div>${result}</div>`;
            }
            terminalOutput.scrollTop = terminalOutput.scrollHeight;
        }
        cmdInput.value = '';
    }
});

// Network visualization
const canvas = document.getElementById('network-canvas');
const ctx = canvas.getContext('2d');
canvas.width = canvas.offsetWidth;
canvas.height = canvas.offsetHeight;

const nodes = [];
for (let i = 0; i < 20; i++) {
    nodes.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        vx: (Math.random() - 0.5) * 2,
        vy: (Math.random() - 0.5) * 2
    });
}

function drawNetwork() {
    ctx.fillStyle = 'rgba(0, 20, 0, 0.1)';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    nodes.forEach(node => {
        node.x += node.vx;
        node.y += node.vy;
        if (node.x < 0 || node.x > canvas.width) node.vx *= -1;
        if (node.y < 0 || node.y > canvas.height) node.vy *= -1;

        ctx.beginPath();
        ctx.arc(node.x, node.y, 3, 0, Math.PI * 2);
        ctx.fillStyle = '#0f0';
        ctx.fill();

        nodes.forEach(other => {
            const dist = Math.hypot(node.x - other.x, node.y - other.y);
            if (dist < 100) {
                ctx.beginPath();
                ctx.moveTo(node.x, node.y);
                ctx.lineTo(other.x, other.y);
                ctx.strokeStyle = `rgba(0, 255, 0, ${1 - dist / 100})`;
                ctx.stroke();
            }
        });
    });

    requestAnimationFrame(drawNetwork);
}

drawNetwork();

// File list
const fileList = document.getElementById('file-list');
const files = ['/bin', '/boot', '/dev', '/etc', '/home', '/lib', '/mnt', '/opt', '/proc', '/root', '/sys', '/tmp', '/usr', '/var'];
files.forEach(file => {
    const div = document.createElement('div');
    div.className = 'file-item';
    div.textContent = file;
    fileList.appendChild(div);
});

// Boot message
terminalOutput.innerHTML = `<div style="color:#0ff">BlazeNeuro OS v1.0 - Neural Interface Active</div>
<div>Type 'help' for available commands</div>`;
