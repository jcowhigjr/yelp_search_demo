/**
 * Language Selector Integration Test (AC5)
 * 
 * Verifies that the language selector:
 * - Does not interfere with theme toggle functionality
 * - Does not interfere with search functionality across locales
 * - Maintains all UI element functionality after locale changes
 * 
 * Requirements:
 * - Rails server must be running on http://localhost:3000 (or TEST_BASE_URL)
 * - All locales must be configured (en, fr, es, pt-BR)
 * 
 * Usage:
 *   npx playwright test test/e2e/language-selector-integration.spec.js
 */

const { test, expect } = require('@playwright/test');

const BASE_URL = process.env.TEST_BASE_URL || 'http://localhost:3000';

test.describe('Language Selector Integration Tests (AC5)', () => {
  
  test('language selector does not interfere with theme toggle', async ({ page }) => {
    await page.goto(BASE_URL);
    
    // Verify theme toggle button exists
    const themeButton = page.locator('button[data-theme-target="button"]');
    await expect(themeButton).toBeVisible();
    
    // Get initial theme icon
    const initialIcon = await page.locator('i[data-theme-target="icon"]').textContent();
    
    // Switch to French
    await page.locator('footer .language-nav a:has-text("Français")').click();
    await page.waitForLoadState('networkidle');
    
    // Verify theme toggle button still exists after language switch
    await expect(themeButton).toBeVisible();
    
    // Click theme toggle to change theme
    await themeButton.click();
    
    // Wait a moment for theme change
    await page.waitForTimeout(300);
    
    // Verify theme icon changed (indicates toggle is working)
    const changedIcon = await page.locator('i[data-theme-target="icon"]').textContent();
    expect(changedIcon).not.toBe(initialIcon);
    
    // Verify theme toggle is still functional
    await expect(themeButton).toBeVisible();
    await expect(page.locator('i[data-theme-target="icon"]')).toBeVisible();
  });

  test('search functionality remains intact across locale changes', async ({ page }) => {
    await page.goto(BASE_URL);
    
    // Verify English search placeholder
    const searchInput = page.locator('input[type="search"]');
    await expect(searchInput).toBeVisible();
    let placeholder = await searchInput.getAttribute('placeholder');
    expect(placeholder).toBe('Search for coffee shops...');
    
    // Verify search button exists and is enabled
    const searchButton = page.locator('button[type="submit"]');
    await expect(searchButton).toBeVisible();
    await expect(searchButton).toBeEnabled();
    
    // Switch to French
    await page.locator('footer .language-nav a:has-text("Français")').click();
    await page.waitForLoadState('networkidle');
    
    // Verify search input still exists
    await expect(searchInput).toBeVisible();
    
    // Verify French placeholder
    placeholder = await searchInput.getAttribute('placeholder');
    expect(placeholder).toBe('Rechercher des cafés...');
    
    // Verify search button is still functional
    await expect(searchButton).toBeVisible();
    await expect(searchButton).toBeEnabled();
    
    // Try to type in search input (verify it's functional)
    await searchInput.fill('test coffee');
    const inputValue = await searchInput.inputValue();
    expect(inputValue).toBe('test coffee');
    
    // Switch to Spanish
    await page.locator('footer .language-nav a:has-text("Español")').click();
    await page.waitForLoadState('networkidle');
    
    // Verify search still works in Spanish
    await expect(searchInput).toBeVisible();
    placeholder = await searchInput.getAttribute('placeholder');
    expect(placeholder).toBe('Buscar cafeterías...');
    
    // Verify search button is still functional
    await expect(searchButton).toBeVisible();
    await expect(searchButton).toBeEnabled();
  });

  test('theme toggle and search work together after multiple locale switches', async ({ page }) => {
    await page.goto(BASE_URL);
    
    const themeButton = page.locator('button[data-theme-target="button"]');
    const searchInput = page.locator('input[type="search"]');
    const searchButton = page.locator('button[type="submit"]');
    
    // Initial state verification
    await expect(themeButton).toBeVisible();
    await expect(searchInput).toBeVisible();
    await expect(searchButton).toBeVisible();
    
    // Switch to French
    await page.locator('footer .language-nav a:has-text("Français")').click();
    await page.waitForLoadState('networkidle');
    
    // Verify all elements still exist
    await expect(themeButton).toBeVisible();
    await expect(searchInput).toBeVisible();
    await expect(searchButton).toBeVisible();
    
    // Toggle theme
    await themeButton.click();
    await page.waitForTimeout(300);
    
    // Verify theme icon still exists (theme toggle worked)
    await expect(page.locator('i[data-theme-target="icon"]')).toBeVisible();
    
    // Type in search
    await searchInput.fill('café');
    expect(await searchInput.inputValue()).toBe('café');
    
    // Switch to Portuguese
    await page.locator('footer .language-nav a:has-text("Português")').click();
    await page.waitForLoadState('networkidle');
    
    // Verify all elements still exist after second language switch
    await expect(themeButton).toBeVisible();
    await expect(searchInput).toBeVisible();
    await expect(searchButton).toBeVisible();
    
    // Verify theme toggle is still clickable
    await themeButton.click();
    await page.waitForTimeout(300);
    await expect(page.locator('i[data-theme-target="icon"]')).toBeVisible();
    
    // Verify search is still functional
    await searchInput.fill('coffee shop');
    expect(await searchInput.inputValue()).toBe('coffee shop');
  });

  test('html lang attribute updates correctly without breaking other functionality', async ({ page }) => {
    await page.goto(BASE_URL);
    
    // Verify initial lang is 'en'
    let htmlLang = await page.evaluate(() => document.documentElement.lang);
    expect(htmlLang).toBe('en');
    
    // Verify theme toggle exists
    const themeButton = page.locator('button[data-theme-target="button"]');
    await expect(themeButton).toBeVisible();
    
    // Switch to French
    await page.locator('footer .language-nav a:has-text("Français")').click();
    await page.waitForLoadState('networkidle');
    
    // Verify lang attribute updated
    htmlLang = await page.evaluate(() => document.documentElement.lang);
    expect(htmlLang).toBe('fr');
    
    // Verify theme toggle still works after lang attribute change
    await expect(themeButton).toBeVisible();
    await themeButton.click();
    await page.waitForTimeout(300);
    await expect(page.locator('i[data-theme-target="icon"]')).toBeVisible();
    
    // Verify search still works after lang attribute change
    const searchInput = page.locator('input[type="search"]');
    await expect(searchInput).toBeVisible();
    await searchInput.fill('test');
    expect(await searchInput.inputValue()).toBe('test');
  });

  test('locale switching preserves page structure and all interactive elements', async ({ page }) => {
    await page.goto(BASE_URL);
    
    // Define all critical elements that should remain functional
    const criticalElements = {
      themeToggle: 'button[data-theme-target="button"]',
      searchInput: 'input[type="search"]',
      searchButton: 'button[type="submit"]',
      languageNav: 'footer .language-nav',
      footer: 'footer'
    };
    
    // Verify all elements exist initially
    for (const [name, selector] of Object.entries(criticalElements)) {
      await expect(page.locator(selector)).toBeVisible({ timeout: 5000 });
    }
    
    // Switch to Spanish
    await page.locator('footer .language-nav a:has-text("Español")').click();
    await page.waitForLoadState('networkidle');
    
    // Verify all elements still exist
    for (const [name, selector] of Object.entries(criticalElements)) {
      await expect(page.locator(selector)).toBeVisible({ timeout: 5000 });
    }
    
    // Switch to Portuguese
    await page.locator('footer .language-nav a:has-text("Português")').click();
    await page.waitForLoadState('networkidle');
    
    // Verify all elements still exist after second switch
    for (const [name, selector] of Object.entries(criticalElements)) {
      await expect(page.locator(selector)).toBeVisible({ timeout: 5000 });
    }
    
    // Verify elements are interactive (not just visible)
    await page.locator('button[data-theme-target="button"]').click();
    await page.locator('input[type="search"]').fill('test');
    
    // If we got here without errors, all elements are functional
    expect(true).toBe(true);
  });

  test('I18n.locale updates are reflected in translated content', async ({ page }) => {
    await page.goto(BASE_URL);
    
    // Check English placeholder
    const searchInput = page.locator('input[type="search"]');
    let placeholder = await searchInput.getAttribute('placeholder');
    expect(placeholder).toContain('Search for coffee shops');
    
    // Switch to French and verify translated content
    await page.locator('footer .language-nav a:has-text("Français")').click();
    await page.waitForLoadState('networkidle');
    
    placeholder = await searchInput.getAttribute('placeholder');
    expect(placeholder).toContain('Rechercher des cafés');
    
    // Verify html lang attribute matches
    const htmlLang = await page.evaluate(() => document.documentElement.lang);
    expect(htmlLang).toBe('fr');
    
    // Verify active language link has correct styling
    const frenchLink = page.locator('footer .language-nav a:has-text("Français")');
    const classList = await frenchLink.getAttribute('class');
    expect(classList).toContain('language-nav__link--active');
  });
});
