
(function () {
    "use strict";

    const THEME_KEY = "studentsphere-theme";

    function applyTheme(theme) {
        const isDark = theme === "dark";

        document.body.classList.toggle("dark", isDark);

        const button = document.getElementById("themeToggle");

        if (button) {
            button.textContent = isDark
                ? "☀️ Light Mode"
                : "🌙 Dark Mode";

            button.setAttribute(
                "aria-pressed",
                String(isDark)
            );
        }
    }

    function initializeTheme() {
        const savedTheme = localStorage.getItem(THEME_KEY) || "light";
        applyTheme(savedTheme);
    }

    window.toggleStudentSphereTheme = function () {
        const isDark = document.body.classList.contains("dark");
        const newTheme = isDark ? "light" : "dark";

        localStorage.setItem(THEME_KEY, newTheme);
        applyTheme(newTheme);
    };

    if (document.readyState === "loading") {
        document.addEventListener(
            "DOMContentLoaded",
            initializeTheme
        );
    } else {
        initializeTheme();
    }
})();
