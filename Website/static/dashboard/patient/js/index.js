
// Sensor Popup Functions
function openSensorPopup(sensorId) {
  document.getElementById(`sensorPopup${sensorId}`).style.display = "block";
}

function closeSensorPopup(sensorId) {
  document.getElementById(`sensorPopup${sensorId}`).style.display = "none";
}

function saveSensorValue(sensorId) {
  var sensorValue = document.getElementById(`sensorValueInput${sensorId}`).value;
  // Add your code to save the value here
  // For now, let's hide the popup
  document.getElementById(`sensorPopup${sensorId}`).style.display = "none";
}

function retakeSensorValue(sensorId) {
  document.getElementById(`sensorValueInput${sensorId}`).value = "";
}

// Function to redirect to the "Book Appointment" page
function redirectToBookAppointment() {
  href = "/book_appointment.html";
}

// Function to redirect to the "Reschedule Appointment" page
function redirectToRescheduleAppointment() {
  window.location.href = "/templates/reschedule_appointment";
}

// Function to redirect to the "Appointment History" page
function redirectToAppointmentHistory() {
  window.location.href = "/templates/appointment_history"; // Replace with the actual URL
}

// Function to redirect to the "Live Vitals" page
function redirectToLiveVitals() {
  window.location.href = "../../../templates/live_vitals.html"; // Replace with the actual URL
}

// Function to redirect to the "Prescriptions" page
function redirectToPrescriptions() {
  window.location.href = "../../../templates/prescriptions.html"; // Replace with the actual URL
}

// Function to redirect to the "Lab Reports" page
function redirectToLabReports() {
  window.location.href = "../../../templates/lab_reports.html"; // Replace with the actual URL
}

// Function to redirect to the "Inpatient Records" page
function redirectToInpatientRecords() {
  window.location.href = "../../../templates/inpatient_records.html"; // Replace with the actual URL
}

// Function to redirect to the "Symptoms Chatbot" page
function redirectToChatbot() {
  window.location.href = "../../../templates/symptoms_chatbot.html"; // Replace with the actual URL
}

function showTrendlineChart() {
  var trendlineChart = document.getElementById("trendlineChart1");
  trendlineChart.style.display = "block";
  plotTrendlineChart(); // Call the function to plot the chart
}

function closeTrendlineChart() {
  var trendlineChart = document.getElementById("trendlineChart1");
  trendlineChart.style.display = "none";
}

function plotTrendlineChart() {
  // Define your data and layout
  var data = [
    {
      x: [1, 2, 3, 4, 5], // X-axis data
      y: [98, 97, 96, 97, 98], // Y-axis data
      type: 'line', // Chart type (line chart in this example)
      marker: { color: 'blue' }, // Marker color
    },
  ];

  var layout = {
    title: 'Heart Rate Trendline',
    xaxis: { title: 'Time' },
    yaxis: { title: 'Heart Rate' },
  };

  // Create the chart
  Plotly.newPlot('trendlineChart1', data, layout);
}