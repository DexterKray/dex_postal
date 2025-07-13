let isDragging = false;
let currentX;
let currentY;
let xOffset = 0;
let yOffset = 0;

document.addEventListener('DOMContentLoaded', function() {
    const postalContainer = document.getElementById('postal-container');
    const saveButton = document.getElementById('save-button');

    if (!postalContainer || !saveButton) {
        console.error('Element not found:', { postalContainer, saveButton });
    }

    postalContainer.addEventListener('mousedown', startDragging);
    saveButton.addEventListener('click', savePosition);

    function startDragging(e) {
        if (!postalContainer.classList.contains('moving')) {
            return;
        }
        const rect = postalContainer.getBoundingClientRect();
        currentX = rect.left;
        currentY = rect.top;
        xOffset = e.clientX - currentX;
        yOffset = e.clientY - currentY;
        isDragging = true;
    }

    document.addEventListener('mousemove', (e) => {
        if (isDragging) {
            e.preventDefault();
            currentX = e.clientX - xOffset;
            currentY = e.clientY - yOffset;
            setPosition(currentX, currentY);
        }
    });

    document.addEventListener('mouseup', () => {
        if (isDragging) {
            isDragging = false;
        }
    });

    document.addEventListener('keydown', (e) => {
        if (e.keyCode === 27 && postalContainer.classList.contains('moving')) {
            fetch(`https://${GetParentResourceName()}/cancelMove`, {
                method: 'POST',
                body: JSON.stringify({})
            }).then(resp => resp.json()).then(resp => {}).catch(err => console.error('Cancel move error:', err));
        }
    });

    function setPosition(x, y) {
        const vw = window.innerWidth;
        const vh = window.innerHeight;
        const xPercent = (x / vw) * 100;
        const yPercent = (y / vh) * 100;
        postalContainer.style.left = `${xPercent}%`;
        postalContainer.style.top = `${yPercent}%`;
        postalContainer.style.right = 'auto';
        postalContainer.style.bottom = 'auto';
    }

    function savePosition() {
        const vw = window.innerWidth;
        const vh = window.innerHeight;
        const rect = postalContainer.getBoundingClientRect();
        const xPercent = (rect.left / vw) * 100;
        const yPercent = (rect.top / vh) * 100;
        fetch(`https://${GetParentResourceName()}/savePosition`, {
            method: 'POST',
            body: JSON.stringify({ x: xPercent, y: yPercent })
        }).then(resp => resp.json()).then(resp => {
            window.postMessage({
                action: 'disableMove',
                showSave: false
            }, '*');
        }).catch(err => console.error('Save error:', err));
    }

    function updateThemeBasedOnTime(hour, minute) {
        // Check if it's day time (06:01 to 20:59) or night time (21:00 to 06:00)
        const isDayTime = (hour > 6 || (hour === 6 && minute >= 1)) && hour < 21;
        
        if (isDayTime) {
            postalContainer.classList.remove('night-theme');
            postalContainer.classList.add('day-theme');
        } else {
            postalContainer.classList.remove('day-theme');
            postalContainer.classList.add('night-theme');
        }
    }

    window.addEventListener('message', function(event) {
        if (event.data.action === 'updatePostal') {
            const postalCodeSpan = document.getElementById('postal-code');
            postalCodeSpan.innerText = `Postal: ${event.data.postal}`;
        }
        if (event.data.action === 'updateTimeTheme') {
            updateThemeBasedOnTime(event.data.hour, event.data.minute);
        }
        if (event.data.action === 'hidePostal') {
            postalContainer.classList.add('hidden');
        }
        if (event.data.action === 'showPostal') {
            postalContainer.classList.remove('hidden');
        }
        if (event.data.action === 'enableMove') {
            postalContainer.classList.add('moving');
            saveButton.classList.remove('hidden');
        }
        if (event.data.action === 'disableMove') {
            postalContainer.classList.remove('moving');
            saveButton.classList.add('hidden');
        }
        if (event.data.action === 'setPosition') {
            postalContainer.style.left = `${event.data.x}%`;
            postalContainer.style.top = `${event.data.y}%`;
            postalContainer.style.right = 'auto';
            postalContainer.style.bottom = 'auto';
        }
    });
});