// Visitor Counter Script
document.addEventListener("DOMContentLoaded", function() {
    // Simulating visitor count with local storage
    let count = localStorage.getItem('visitorCount');
    
    if (count === null) {
        count = 1;
    } else {
        count = parseInt(count) + 1;
    }

    // Save new count in local storage
    localStorage.setItem('visitorCount', count);

    // Display the visitor count
    document.getElementById('visitorCount').textContent = count;
});
