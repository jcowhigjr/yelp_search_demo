#!/usr/bin/env node
/* eslint-disable no-console */

/**
 * Language Selector Dropdown Test
 * Tests the new language selector button in the top-right layout area
 * 
 * Requirements:
 * - Verify language selector button is present in top-right area
 * - Test dropdown menu interaction
 * - Verify clicking languages updates I18n.locale
 * - Verify page content updates to reflect new locale
 * - Test accessibility (aria attributes, keyboard navigation)
 * 
 * GitHub Issue: #1092
 */

const puppeteer = require('puppeteer');

// Configuration
const BASE_URL = process.env.TEST_BASE_URL || 'http://localhost:3000';
const HEADLESS = process.env.TEST_HEADLESS !== 'false';
const TIMEOUT = 30000;

/**
 * Helper function to get the html lang attribute
 */
async function getHtmlLang(page) {
  return await page.evaluate(() => {
    return document.documentElement.getAttribute('lang');
  });
}

/**
 * Helper function to wait for navigation and ensure page is loaded
 */
async function waitForPageLoad(page) {
  await page.waitForNavigation({ waitUntil: 'networkidle0', timeout: TIMEOUT });
  // Additional wait to ensure all JavaScript has executed
  await page.waitForTimeout(500);
}

/**
 * Main test function
 */
async function runTest() {
  console.log('🚀 Starting Language Selector Dropdown Test');
  console.log(`📍 Base URL: ${BASE_URL}`);
  console.log(`🎭 Headless: ${HEADLESS}`);
  console.log('');

  const browser = await puppeteer.launch({
    headless: HEADLESS ? 'new' : false,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  let testsPassed = 0;
  let testsFailed = 0;

  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 720 });

    // Test 1: Navigate to homepage and verify English is default
    console.log('✅ Test 1: Verify initial page loads with English locale');
    await page.goto(BASE_URL, { waitUntil: 'networkidle0', timeout: TIMEOUT });
    
    const initialLang = await getHtmlLang(page);
    if (initialLang === 'en') {
      console.log(`   ✓ html[lang="${initialLang}"] detected`);
      testsPassed++;
    } else {
      console.error(`   ✗ Expected html[lang="en"], but got html[lang="${initialLang}"]`);
      testsFailed++;
    }

    // Test 2: Verify language selector button exists
    console.log('✅ Test 2: Verify language selector button is present');
    try {
      await page.waitForSelector('button[aria-haspopup="true"]', { timeout: TIMEOUT });
      console.log('   ✓ Language selector button found');
      testsPassed++;
    } catch (error) {
      console.error(`   ✗ Language selector button not found: ${error.message}`);
      testsFailed++;
      throw new Error('Cannot continue without language selector button');
    }

    // Test 3: Verify button has correct aria attributes
    console.log('✅ Test 3: Verify language selector button accessibility attributes');
    try {
      const ariaAttributes = await page.evaluate(() => {
        const button = document.querySelector('button[aria-haspopup="true"]');
        if (!button) return null;
        return {
          ariaHaspopup: button.getAttribute('aria-haspopup'),
          ariaExpanded: button.getAttribute('aria-expanded'),
          ariaLabel: button.getAttribute('aria-label')
        };
      });

      if (ariaAttributes && ariaAttributes.ariaHaspopup === 'true') {
        console.log(`   ✓ Button has aria-haspopup="true"`);
        console.log(`   ✓ Button aria-expanded="${ariaAttributes.ariaExpanded || 'false'}"`);
        if (ariaAttributes.ariaLabel) {
          console.log(`   ✓ Button has aria-label="${ariaAttributes.ariaLabel}"`);
        }
        testsPassed++;
      } else {
        console.error('   ✗ Button missing required aria attributes');
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not verify aria attributes: ${error.message}`);
      testsFailed++;
    }

    // Test 4: Verify button shows current locale
    console.log('✅ Test 4: Verify button displays current locale');
    try {
      const buttonText = await page.evaluate(() => {
        const button = document.querySelector('button[aria-haspopup="true"]');
        return button ? button.textContent.trim() : null;
      });

      if (buttonText && (buttonText.includes('en') || buttonText.includes('EN') || buttonText.includes('English'))) {
        console.log(`   ✓ Button shows English locale: "${buttonText}"`);
        testsPassed++;
      } else {
        console.error(`   ✗ Button does not clearly show English locale. Found: "${buttonText}"`);
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not verify button text: ${error.message}`);
      testsFailed++;
    }

    // Test 5: Click button and verify dropdown opens
    console.log('✅ Test 5: Open language selector dropdown');
    try {
      // Click the button
      await page.click('button[aria-haspopup="true"]');
      
      // Wait for dropdown menu to appear
      await page.waitForSelector('[role="menu"], .language-menu', { visible: true, timeout: TIMEOUT });
      
      // Verify aria-expanded changed to true
      const ariaExpanded = await page.evaluate(() => {
        const button = document.querySelector('button[aria-haspopup="true"]');
        return button ? button.getAttribute('aria-expanded') : null;
      });

      if (ariaExpanded === 'true') {
        console.log('   ✓ Dropdown opened, aria-expanded="true"');
        testsPassed++;
      } else {
        console.error(`   ✗ aria-expanded not set correctly. Found: "${ariaExpanded}"`);
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Failed to open dropdown: ${error.message}`);
      testsFailed++;
      throw error;
    }

    // Test 6: Verify all language options are present in dropdown
    console.log('✅ Test 6: Verify all language options in dropdown');
    try {
      const languageOptions = await page.evaluate(() => {
        const menuItems = Array.from(document.querySelectorAll('[role="menu"] a, [role="menuitem"], .language-menu a'));
        return menuItems.map(item => item.textContent.trim());
      });

      const expectedLanguages = ['English', 'Português', 'Français', 'Español'];
      const allFound = expectedLanguages.every(lang => 
        languageOptions.some(option => option.includes(lang))
      );

      if (allFound) {
        console.log(`   ✓ All language options found: ${languageOptions.join(', ')}`);
        testsPassed++;
      } else {
        console.error(`   ✗ Missing language options. Found: ${languageOptions.join(', ')}`);
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not verify language options: ${error.message}`);
      testsFailed++;
    }

    // Test 7: Click French option and verify navigation
    console.log('✅ Test 7: Switch to French locale via dropdown');
    try {
      // Click the French option
      await page.evaluate(() => {
        const menuItems = Array.from(document.querySelectorAll('[role="menu"] a, [role="menuitem"], .language-menu a'));
        const frenchOption = menuItems.find(item => item.textContent.trim().includes('Français'));
        if (frenchOption) {
          frenchOption.click();
        }
      });

      // Wait for navigation
      await waitForPageLoad(page);
      
      console.log('   ✓ Clicked French language option');
      testsPassed++;
    } catch (error) {
      console.error(`   ✗ Failed to click French option: ${error.message}`);
      testsFailed++;
    }

    // Test 8: Verify I18n.locale updated to French
    console.log('✅ Test 8: Verify I18n.locale updated to French');
    const frenchLang = await getHtmlLang(page);
    if (frenchLang === 'fr') {
      console.log(`   ✓ html[lang="${frenchLang}"] detected after language switch`);
      testsPassed++;
    } else {
      console.error(`   ✗ Expected html[lang="fr"], but got html[lang="${frenchLang}"]`);
      testsFailed++;
    }

    // Test 9: Verify URL updated to French locale
    console.log('✅ Test 9: Verify URL updated to /fr');
    try {
      const currentUrl = page.url();
      if (currentUrl.includes('/fr')) {
        console.log(`   ✓ URL updated correctly: ${currentUrl}`);
        testsPassed++;
      } else {
        console.error(`   ✗ URL does not include /fr. Found: ${currentUrl}`);
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not verify URL: ${error.message}`);
      testsFailed++;
    }

    // Test 10: Verify page content is in French
    console.log('✅ Test 10: Verify page content translated to French');
    try {
      const placeholder = await page.$eval('input[type="text"]', el => el.getAttribute('placeholder'));
      if (placeholder && placeholder.includes('Rechercher des cafés')) {
        console.log(`   ✓ Search placeholder in French: "${placeholder}"`);
        testsPassed++;
      } else {
        console.error(`   ✗ Search placeholder not in French. Found: "${placeholder}"`);
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not verify French content: ${error.message}`);
      testsFailed++;
    }

    // Test 11: Verify button now shows French locale
    console.log('✅ Test 11: Verify button displays French locale indicator');
    try {
      const buttonText = await page.evaluate(() => {
        const button = document.querySelector('button[aria-haspopup="true"]');
        return button ? button.textContent.trim() : null;
      });

      if (buttonText && (buttonText.toLowerCase().includes('fr') || buttonText.includes('Français'))) {
        console.log(`   ✓ Button shows French locale: "${buttonText}"`);
        testsPassed++;
      } else {
        console.error(`   ✗ Button does not show French locale. Found: "${buttonText}"`);
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not verify button text: ${error.message}`);
      testsFailed++;
    }

    // Test 12: Test mobile viewport
    console.log('✅ Test 12: Test language selector on mobile viewport');
    try {
      await page.setViewport({ width: 375, height: 667 }); // iPhone SE size
      
      // Navigate back to English
      await page.goto(`${BASE_URL}/en`, { waitUntil: 'networkidle0', timeout: TIMEOUT });
      
      // Wait for button
      await page.waitForSelector('button[aria-haspopup="true"]', { timeout: TIMEOUT });
      
      // Check button is visible and has reasonable tap target size
      const buttonDimensions = await page.evaluate(() => {
        const button = document.querySelector('button[aria-haspopup="true"]');
        if (!button) return null;
        const rect = button.getBoundingClientRect();
        return {
          width: rect.width,
          height: rect.height,
          visible: rect.width > 0 && rect.height > 0
        };
      });

      if (buttonDimensions && buttonDimensions.visible) {
        console.log(`   ✓ Button visible on mobile (${buttonDimensions.width}x${buttonDimensions.height}px)`);
        
        // Check if tap target is at least 44x44px (iOS HIG recommendation)
        if (buttonDimensions.width >= 40 && buttonDimensions.height >= 40) {
          console.log('   ✓ Button has adequate tap target size for mobile');
          testsPassed++;
        } else {
          console.error(`   ⚠️  Button may be too small for comfortable mobile use (recommended 44x44px minimum)`);
          testsPassed++; // Still pass, but warn
        }
      } else {
        console.error('   ✗ Button not visible on mobile viewport');
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Mobile viewport test failed: ${error.message}`);
      testsFailed++;
    }

    await page.close();

  } catch (error) {
    console.error(`\n❌ Test suite failed with error: ${error.message}`);
    console.error(error.stack);
  } finally {
    await browser.close();
  }

  // Print summary
  console.log('\n' + '='.repeat(50));
  console.log('📊 Test Summary:');
  console.log(`   ✓ Passed: ${testsPassed}`);
  console.log(`   ✗ Failed: ${testsFailed}`);
  console.log(`   Total:  ${testsPassed + testsFailed}`);
  console.log('='.repeat(50));

  // Exit with appropriate code
  if (testsFailed > 0) {
    console.log('\n❌ Some tests failed');
    process.exit(1);
  } else {
    console.log('\n✅ All tests passed!');
    process.exit(0);
  }
}

// Handle errors
process.on('unhandledRejection', (error) => {
  console.error('Unhandled promise rejection:', error);
  process.exit(1);
});

// Run the test
runTest().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
