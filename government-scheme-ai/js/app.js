/* Global Application Scripts - Theme Toggle & Navigation */

document.addEventListener('DOMContentLoaded', () => {
  // 1. Mobile Navigation Menu Toggle
  const navToggle = document.getElementById('nav-toggle');
  const navMenu = document.getElementById('nav-menu');

  if (navToggle && navMenu) {
    navToggle.addEventListener('click', () => {
      navMenu.classList.toggle('show');
      const icon = navToggle.querySelector('i');
      if (navMenu.classList.contains('show')) {
        icon.className = 'fa-solid fa-xmark';
      } else {
        icon.className = 'fa-solid fa-bars';
      }
    });
  }

  // 2. Light / Dark Theme Switcher
  const themeToggleBtn = document.getElementById('theme-toggle');
  const body = document.body;

  // Read saved preference, default to light theme
  const savedTheme = localStorage.getItem('theme') || 'light-theme';
  body.className = savedTheme;
  updateThemeIcon(savedTheme);

  if (themeToggleBtn) {
    themeToggleBtn.addEventListener('click', () => {
      if (body.classList.contains('light-theme')) {
        body.className = 'dark-theme';
        localStorage.setItem('theme', 'dark-theme');
        updateThemeIcon('dark-theme');
      } else {
        body.className = 'light-theme';
        localStorage.setItem('theme', 'light-theme');
        updateThemeIcon('light-theme');
      }
    });
  }

  function updateThemeIcon(theme) {
    if (!themeToggleBtn) return;
    const icon = themeToggleBtn.querySelector('i');
    if (theme === 'dark-theme') {
      icon.className = 'fa-solid fa-sun';
    } else {
      icon.className = 'fa-solid fa-moon';
    }
  }

  // 3. Global Authentication Check
  const currentPath = window.location.pathname;
  const isAuthPage = currentPath.endsWith('index.html') || currentPath === '/' || currentPath === '';
  const isAdminPage = currentPath.endsWith('admin.html');
  
  if (!isAuthPage && !isAdminPage) {
    if (sessionStorage.getItem('user_authenticated') !== 'true') {
      window.location.href = 'index.html';
    }
  }

  // 4. Logout Logic
  const logoutBtn = document.getElementById('nav-logout');
  if (logoutBtn) {
    logoutBtn.addEventListener('click', (e) => {
      e.preventDefault();
      sessionStorage.removeItem('user_authenticated');
      sessionStorage.removeItem('user_profile_id');
      sessionStorage.removeItem('user_name');
      window.location.href = 'index.html';
    });
  }
});
