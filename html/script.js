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
    } else {
        console.log('Elements found:', { postalContainer, saveButton });
    }

    postalContainer.addEventListener('mousedown', startDragging);
    saveButton.addEventListener('click', savePosition);

    function startDragging(e) {
        if (!postalContainer.classList.contains('moving')) {
            console.log('Cannot drag: .moving class not present');
            return;
        }
        const rect = postalContainer.getBoundingClientRect();
        currentX = rect.left;
        currentY = rect.top;
        xOffset = e.clientX - currentX;
        yOffset = e.clientY - currentY;
        isDragging = true;
        console.log('Started dragging at x:', currentX, 'y:', currentY);
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
            console.log('Stopped dragging at x:', currentX, 'y:', currentY);
            isDragging = false;
        }
    });

    document.addEventListener('keydown', (e) => {
        if (e.keyCode === 27 && postalContainer.classList.contains('moving')) {
            console.log('ESC pressed, canceling move');
            fetch(`https://${GetParentResourceName()}/cancelMove`, {
                method: 'POST',
                body: JSON.stringify({})
            }).then(resp => resp.json()).then(resp => console.log('Cancel response:', resp));
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
        console.log('Save button clicked');
        const vw = window.innerWidth;
        const vh = window.innerHeight;
        const rect = postalContainer.getBoundingClientRect();
        const xPercent = (rect.left / vw) * 100;
        const yPercent = (rect.top / vh) * 100;
        console.log('Saving position: x=', xPercent, 'y=', yPercent);
        fetch(`https://${GetParentResourceName()}/savePosition`, {
            method: 'POST',
            body: JSON.stringify({ x: xPercent, y: yPercent })
        }).then(resp => resp.json()).then(resp => {
            console.log('Save response:', resp);
            window.postMessage({
                action: 'disableMove',
                showSave: false
            }, '*');
        }).catch(err => console.error('Save error:', err));
    }

    window.addEventListener('message', function(event) {
        if (event.data.action === 'updatePostal') {
            const postalCodeSpan = document.getElementById('postal-code');
            postalCodeSpan.innerText = `Postal: ${event.data.postal}`;
        }
        if (event.data.action === 'hidePostal') {
            postalContainer.classList.add('hidden');
        }
        if (event.data.action === 'showPostal') {
            postalContainer.classList.remove('hidden');
        }
        if (event.data.action === 'enableMove') {
            console.log('Applying .moving class');
            postalContainer.classList.add('moving');
            saveButton.classList.remove('hidden');
        }
        if (event.data.action === 'disableMove') {
            console.log('Removing .moving class');
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