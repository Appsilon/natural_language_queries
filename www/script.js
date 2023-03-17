/* Open when someone clicks on the span element */
function openNav() {
  document.getElementById("myNav").style.width = "100%";
}

/* Close when someone clicks on the "x" symbol inside the overlay */
function closeNav() {
  document.getElementById("myNav").style.width = "0%";
}

function toggleFilters() {
  document.querySelector(".filter-query").classList.toggle("nlq-styling")
  document.querySelector(".filter-query").classList.toggle("default-styling")
}