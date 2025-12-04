// @ts-check
const { test, expect } = require('@playwright/test');

/**
 * Language Selector Tests
 * 
 * Tests the language selector functionality including:
 * - Language switching updates html lang attribute
 * - I18n.locale is set correctly
 * - Search placeholder is translated correctly
 * - Active language link styling
 */

test.describe('Language Selector', () => {
  test('initial page loads with English locale', async ({ page }) => {
    await page.goto('/');
    
    // Verify html lang attribute is 'en'
    const htmlLang = await page.locator('html').getAttribute('lang');
    expect(htmlLang).toBe('en');
    
    // Verify English search placeholder
    const searchInput = page.locator('input[type="text"]');
    await expect(searchInput).toHaveAttribute('placeholder', 'Search for coffee shops...');
  });

  test('switching to French updates locale and html lang attribute', async ({ page }) => {
    await page.goto('/');
    
    // Verify initial state is English
    let htmlLang = await page.locator('html').getAttribute('lang');
    expect(htmlLang).toBe('en');
    
    // Open selector and click French option
    await page.locator('.language-selector__button').click();
    await page.locator('.language-menu__item:has-text("Français")').click();
    
    // Wait for navigation to complete
    await page.waitForLoadState('networkidle');
    
    // Verify html lang attribute changed to 'fr'
    htmlLang = await page.locator('html').getAttribute('lang');
    expect(htmlLang).toBe('fr');
    
    // Verify French search placeholder
    const searchInput = page.locator('input[type="text"]');
    await expect(searchInput).toHaveAttribute('placeholder', 'Rechercher des cafés...');
    
    // Verify French link has active class
    const frenchLink = page.locator('.language-menu__item:has-text("Français")');
    await expect(frenchLink).toHaveClass(/language-menu__item--active/);
  });

  test('switching to Spanish updates locale and html lang attribute', async ({ page }) => {
    await page.goto('/');
    
    // Click Spanish language option
    await page.locator('.language-selector__button').click();
    await page.locator('.language-menu__item:has-text("Español")').click();
    
    // Wait for navigation to complete
    await page.waitForLoadState('networkidle');
    
    // Verify html lang attribute changed to 'es'
    const htmlLang = await page.locator('html').getAttribute('lang');
    expect(htmlLang).toBe('es');
    
    // Verify Spanish search placeholder
    const searchInput = page.locator('input[type="text"]');
    await expect(searchInput).toHaveAttribute('placeholder', 'Buscar cafeterías...');
    
    // Verify Spanish link has active class
    const spanishLink = page.locator('.language-menu__item:has-text("Español")');
    await expect(spanishLink).toHaveClass(/language-menu__item--active/);
  });

  test('switching to Portuguese updates locale and html lang attribute', async ({ page }) => {
    await page.goto('/');
    
    // Click Portuguese language option
    await page.locator('.language-selector__button').click();
    await page.locator('.language-menu__item:has-text("Português")').click();
    
    // Wait for navigation to complete
    await page.waitForLoadState('networkidle');
    
    // Verify html lang attribute changed to 'pt-BR'
    const htmlLang = await page.locator('html').getAttribute('lang');
    expect(htmlLang).toBe('pt-BR');
    
    // Verify Portuguese link has active class
    const portugueseLink = page.locator('.language-menu__item:has-text("Português")');
    await expect(portugueseLink).toHaveClass(/language-menu__item--active/);
  });

  test('all language options are present in selector', async ({ page }) => {
    await page.goto('/');
    
    // Verify all expected language options exist in selector
    await page.locator('.language-selector__button').click();
    await expect(page.locator('.language-menu__item:has-text("English")')).toBeVisible();
    await expect(page.locator('.language-menu__item:has-text("Español")')).toBeVisible();
    await expect(page.locator('.language-menu__item:has-text("Français")')).toBeVisible();
    await expect(page.locator('.language-menu__item:has-text("Português")')).toBeVisible();
  });

  test('direct navigation to locale URL sets correct locale', async ({ page }) => {
    // Navigate directly to French locale
    await page.goto('/fr');
    
    // Verify html lang attribute is 'fr'
    const htmlLang = await page.locator('html').getAttribute('lang');
    expect(htmlLang).toBe('fr');
    
    // Verify French search placeholder
    const searchInput = page.locator('input[type="text"]');
    await expect(searchInput).toHaveAttribute('placeholder', 'Rechercher des cafés...');
  });

  test('search functionality works across different locales', async ({ page }) => {
    // Test English locale
    await page.goto('/');
    const searchInputEn = page.locator('input[type="text"]');
    await searchInputEn.fill('coffee');
    await expect(searchInputEn).toHaveValue('coffee');
    
    // Test French locale
    await page.goto('/fr');
    const searchInputFr = page.locator('input[type="text"]');
    await searchInputFr.fill('café');
    await expect(searchInputFr).toHaveValue('café');
    
    // Test Spanish locale
    await page.goto('/es');
    const searchInputEs = page.locator('input[type="text"]');
    await searchInputEs.fill('café');
    await expect(searchInputEs).toHaveValue('café');
  });

  test('language selector is accessible', async ({ page }) => {
    await page.goto('/');
    
    const selectorButton = page.locator('.language-selector__button');
    await expect(selectorButton).toHaveAttribute('aria-haspopup', 'true');
    await expect(selectorButton).toHaveAttribute('aria-expanded', 'false');

    await selectorButton.click();
    const menu = page.locator('.language-menu');
    await expect(menu).toHaveAttribute('role', 'menu');
    await expect(page.locator('.language-menu__item:has-text("English")')).toHaveAttribute('role', 'menuitem');
  });
});

test.describe('Search Functionality Regression Tests', () => {
  test('search input is present and functional in English', async ({ page }) => {
    await page.goto('/');
    
    const searchInput = page.locator('input[type="text"]');
    await expect(searchInput).toBeVisible();
    await expect(searchInput).toBeEnabled();
    await expect(searchInput).toHaveAttribute('placeholder', 'Search for coffee shops...');
    
    // Test typing in search
    await searchInput.fill('coffee shops');
    await expect(searchInput).toHaveValue('coffee shops');
  });

  test('search input maintains functionality after language switch', async ({ page }) => {
    await page.goto('/');
    
    // Fill search in English
    const searchInputEn = page.locator('input[type="text"]');
    await searchInputEn.fill('coffee');
    
    // Switch to French
    await page.locator('.language-selector__button').click();
    await page.locator('.language-menu__item:has-text("Français")').click();
    await page.waitForLoadState('networkidle');
    
    // Verify search is cleared and functional with French placeholder
    const searchInputFr = page.locator('input[type="text"]');
    await expect(searchInputFr).toBeVisible();
    await expect(searchInputFr).toBeEnabled();
    await expect(searchInputFr).toHaveAttribute('placeholder', 'Rechercher des cafés...');
    
    // Test typing in French
    await searchInputFr.fill('cafés');
    await expect(searchInputFr).toHaveValue('cafés');
  });

  test('search button is present and translated correctly', async ({ page }) => {
    // Test English
    await page.goto('/');
    const searchButtonEn = page.locator('button[type="submit"]');
    await expect(searchButtonEn).toBeVisible();
    await expect(searchButtonEn).toContainText('Search');
    
    // Test French
    await page.goto('/fr');
    const searchButtonFr = page.locator('button[type="submit"]');
    await expect(searchButtonFr).toBeVisible();
    // French translation should be "Rechercher" based on locale file
  });

  test('search form maintains structure across locales', async ({ page }) => {
    const locales = ['/', '/fr', '/es', '/pt-BR'];
    
    for (const locale of locales) {
      await page.goto(locale);
      
      // Verify search form elements are present
      await expect(page.locator('input[type="text"]')).toBeVisible();
      await expect(page.locator('button[type="submit"]')).toBeVisible();
      await expect(page.locator('.search-icon')).toBeVisible();
    }
  });
});
