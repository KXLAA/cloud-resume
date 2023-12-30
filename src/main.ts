function getTotalVisitorCount() {
  return 100;
}

function updateVisitorCount(count: string) {
  const element = document.getElementById("visitor-count");

  if (element) {
    element.textContent = count;
  }
}

// Function to generate a random unique identifier
function generateUniqueID() {
  return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function (c) {
    var r = (Math.random() * 16) | 0,
      v = c === "x" ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
}

// Function to check if a cookie exists
function getCookie(name: string): string {
  const cookies = Object.fromEntries(
    document.cookie.split("; ").map((v) => v.split(/=(.*)/s))
  );

  return cookies[name];
}

// Function to set a cookie
function setCookie(name: string, value: string, days: number) {
  let expires = "";

  if (days) {
    const date = new Date();
    date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000);
    expires = "; expires=" + date.toUTCString();
  }
  document.cookie = name + "=" + value + expires + "; path=/";
}

// Function to track unique visitors
function trackUniqueVisitors() {
  let uniqueID = getCookie("uniqueID");

  if (!uniqueID) {
    // If no unique identifier exists, generate one and set a cookie
    uniqueID = generateUniqueID();
    setCookie("uniqueID", uniqueID, 365); // Cookie expires in 365 days

    // Increment your unique visitors count or send the uniqueID to your server for tracking
    // Example: You could send an HTTP request to your server with the uniqueID
    // axios.post('/track-visitor', { uniqueID });

    console.log("New unique visitor tracked");
  } else {
    console.log("Returning visitor");
  }

  const totalVisitorCount = getTotalVisitorCount();
  updateVisitorCount(Number(totalVisitorCount).toLocaleString());
}

trackUniqueVisitors();
