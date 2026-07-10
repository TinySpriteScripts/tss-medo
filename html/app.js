const root = document.getElementById('overhead-root');
const groups = new Map();
const labels = new Map();

let config = {
    AnchorOffset: { X: 0, Y: -28 },
    StackGap: 6,
    TransitionDuration: 80,
    DefaultStyle: {}
};

const pixelProperties = new Set([
    'BorderWidth', 'BorderRadius', 'FontSize', 'LetterSpacing', 'MinWidth', 'MaxWidth'
]);

const styleProperties = {
    BackgroundColour: 'backgroundColor',
    TextColour: 'color',
    BorderColour: 'borderColor',
    BorderWidth: 'borderWidth',
    BorderStyle: 'borderStyle',
    BorderRadius: 'borderRadius',
    FontFamily: 'fontFamily',
    FontSize: 'fontSize',
    FontWeight: 'fontWeight',
    LineHeight: 'lineHeight',
    LetterSpacing: 'letterSpacing',
    Padding: 'padding',
    MinWidth: 'minWidth',
    MaxWidth: 'maxWidth',
    TextAlign: 'textAlign',
    BoxShadow: 'boxShadow',
    TextShadow: 'textShadow',
    Opacity: 'opacity'
};

function cssValue(key, value) {
    if (pixelProperties.has(key) && typeof value === 'number') return `${value}px`;
    return String(value);
}

function applyStyle(element, overrides = {}) {
    const combined = { ...(config.DefaultStyle || {}), ...overrides };
    Object.entries(styleProperties).forEach(([configKey, cssKey]) => {
        const value = combined[configKey];
        if (value !== undefined && value !== null) {
            element.style[cssKey] = cssValue(configKey, value);
        }
    });
}

function getGroup(playerId) {
    const key = String(playerId);
    if (groups.has(key)) return groups.get(key);

    const element = document.createElement('section');
    element.className = 'overhead-group';
    element.dataset.playerId = key;
    root.appendChild(element);
    groups.set(key, element);
    return element;
}

function removeLabel(id) {
    const key = String(id);
    const entry = labels.get(key);
    if (!entry) return;

    const group = entry.element.parentElement;
    entry.element.remove();
    labels.delete(key);

    if (group && group.childElementCount === 0) {
        groups.delete(group.dataset.playerId);
        group.remove();
    }
}

function showLabel(label) {
    removeLabel(label.id);
    const group = getGroup(label.playerId);
    const element = document.createElement('div');
    element.className = 'overhead-box';
    element.dataset.labelId = String(label.id);
    element.textContent = String(label.text || '');
    applyStyle(element, label.style);
    group.appendChild(element);
    labels.set(String(label.id), { element, playerId: String(label.playerId) });
}

function configure(nextConfig) {
    config = { ...config, ...(nextConfig || {}) };
    const anchor = config.AnchorOffset || {};
    document.documentElement.style.setProperty('--anchor-x', `${Number(anchor.X) || 0}px`);
    document.documentElement.style.setProperty('--anchor-y', `${Number(anchor.Y) || 0}px`);
    document.documentElement.style.setProperty('--stack-gap', `${Number(config.StackGap) || 0}px`);
    document.documentElement.style.setProperty('--transition-duration', `${Number(config.TransitionDuration) || 0}ms`);
}

function updatePositions(players = []) {
    groups.forEach((group) => group.classList.remove('is-visible'));

    players.forEach((player) => {
        const group = groups.get(String(player.id));
        if (!group) return;

        (player.labels || []).forEach((labelState) => {
            const label = labels.get(String(labelState.id));
            if (label) label.element.classList.toggle('is-hidden', !labelState.visible);
        });

        if (!player.visible || !Number.isFinite(player.x) || !Number.isFinite(player.y)) return;
        group.style.left = `${player.x * 100}%`;
        group.style.top = `${player.y * 100}%`;
        group.style.setProperty('--distance-scale', String(player.scale || 1));
        group.classList.add('is-visible');
    });
}

function reset() {
    labels.clear();
    groups.clear();
    root.replaceChildren();
}

window.addEventListener('message', ({ data }) => {
    if (!data || typeof data.action !== 'string') return;

    if (data.action === 'configure') configure(data.config);
    if (data.action === 'show' && data.label) showLabel(data.label);
    if (data.action === 'remove') removeLabel(data.id);
    if (data.action === 'positions') updatePositions(data.players);
    if (data.action === 'reset') reset();
});

fetch(`https://${GetParentResourceName()}/ready`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: '{}'
}).catch(() => {});
