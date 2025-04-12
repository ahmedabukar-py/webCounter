// Wait for the DOM content to fully load before executing the script
document.addEventListener("DOMContentLoaded", async function () {
    // Unique identifier for the page to track its visitor count
    const pageId = "home";

    // Replace this URL with your actual API Gateway URL including the resource path
    const apiUrl = "https://6f0ubtmmd7.execute-api.us-east-1.amazonaws.com/dev/visitor-count";

    try {
        // Send a POST request to the API Gateway endpoint
        const response = await fetch(apiUrl, {
            method: "POST", // Use POST method as per API design
            headers: {
                "Content-Type": "application/json", // Specify the request content type
            },
            body: JSON.stringify({ pageId }), // Include pageId in the request body as JSON
        });

        // Check if the response status is OK (status code 200-299)
        if (response.ok) {
            // Parse the JSON response
            const data = await response.json();

            // Update the DOM element with the visitor count
            // Make sure there's an element with id="visitorCount" in your HTML
            document.getElementById("visitorCount").textContent = data.VisitorCount;
        } else {
            // Log an error message if the request fails
            console.error("Failed to fetch visitor count. Status:", response.status);
        }
    } catch (error) {
        // Log any unexpected errors during the fetch process
        console.error("Error occurred while fetching visitor count:", error);
    }
});
// Visitor Counter Script
/*
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
*/
