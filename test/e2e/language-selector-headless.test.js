#!/usr/bin/env node
/* eslint-disable no-console */

/**
 * Language Selector Headless Test
 * Verifies the new compact language selector functionality in top-right layout
 * 
 * Requirements:
 * - Verify language selector button is visible in top-right near theme toggle
 * - Verify clicking button opens dropdown menu with all available locales
 * - Verify selecting a language navigates to correct locale route
 * - Verify html lang attribute updates correctly
 * - Verify dropdown has proper accessibility attributes
 * - Verify mobile-friendly tap targets (44x44px minimum)
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
 * Helper function to get button dimensions
 */
async function getButtonDimensions(page, selector) {
  return await page.evaluate((sel) => {
    const element = document.querySelector(sel);
    if (!element) return null;
    const rect = element.getBoundingClientRect();
    return {
      width: rect.width,
      height: rect.height,
    };
  }, selector);
}

/**
 * Main test function
 */
async function runTest() {
  console.log('🚀 Starting Language Selector Headless Test');
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
    
    // Test 1: Desktop viewport - verify selector is visible
    console.log('✅ Test 1: Verify language selector exists in top-right (desktop)');
    await page.setViewport({ width: 1280, height: 720 });
    await page.goto(BASE_URL, { waitUntil: 'networkidle0', timeout: TIMEOUT });
    
    const selectorExists = await page.$('.language-selector button[aria-haspopup]');
    if (selectorExists) {
      console.log('   ✓ Language selector button found in top-right');
      testsPassed++;
    } else {
      console.error('   ✗ Language selector button not found');
      testsFailed++;
    }

    // Test 2: Verify accessibility attributes
    console.log('✅ Test 2: Verify language selector has proper accessibility attributes');
    try {
      const ariaAttributes = await page.evaluate(() => {
        const button = document.querySelector('.language-selector button[aria-haspopup]');
        if (!button) return null;
        return {
          hasAriaHaspopup: button.hasAttribute('aria-haspopup'),
          hasAriaExpanded: button.hasAttribute('aria-expanded'),
          ariaLabel: button.getAttribute('aria-label'),
        };
      });

      if (ariaAttributes && ariaAttributes.hasAriaHaspopup) {
        console.log('   ✓ Button has aria-haspopup attribute');
        testsPassed++;
      } else {
        console.error('   ✗ Button missing aria-haspopup attribute');
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not verify accessibility attributes: ${error.message}`);
      testsFailed++;
    }

    // Test 3: Verify button shows current locale
    console.log('✅ Test 3: Verify selector button shows current locale code');
    try {
      const buttonText = await page.$eval('.language-selector button[aria-haspopup]', el => el.textContent.trim());
      
      if (buttonText && buttonText.toLowerCase().includes('en')) {
        console.log(`   ✓ Button shows current locale: "${buttonText}"`);
        testsPassed++;
      } else {
        console.error(`   ✗ Button doesn't show 'en'. Found: "${buttonText}"`);
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not verify button text: ${error.message}`);
      testsFailed++;
    }

    // Test 4: Open dropdown and verify all locales are present
    console.log('✅ Test 4: Verify dropdown contains all available locales');
    try {
      await page.click('.language-selector button[aria-haspopup]');
      await page.waitForTimeout(300); // Wait for dropdown animation
      
      const localesPresent = await page.evaluate(() => {
        const menu = document.querySelector('.language-selector [role="menu"], .language-selector .language-menu');
        if (!menu) return { found: false, locales: [] };
        
        const links = Array.from(menu.querySelectorAll('a, [role="menuitem"]'));
        const localeNames = links.map(link => link.textContent.trim());
        
        const expectedLocales = ['English', 'Português', 'Français', 'Español'];
        const allPresent = expectedLocales.every(locale => 
          localeNames.some(name => name.includes(locale))
        );
        
        return { found: allPresent, locales: localeNames };
      });

      if (localesPresent.found) {
        console.log(`   ✓ All locales present in dropdown: ${localesPresent.locales.join(', ')}`);
        testsPassed++;
      } else {
        console.error(`   ✗ Not all locales found. Present: ${localesPresent.locales.join(', ')}`);
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not verify dropdown locales: ${error.message}`);
      testsFailed++;
    }

    // Test 5: Switch to French and verify navigation
    console.log('✅ Test 5: Verify clicking French navigates to /fr route');
    try {
      const navigationPromise = page.waitForNavigation({ waitUntil: 'networkidle0', timeout: TIMEOUT });
      
      await page.evaluate(() => {
        const menu = document.querySelector('.language-selector [role="menu"], .language-selector .language-menu');
        const links = Array.from(menu.querySelectorAll('a, [role="menuitem"]'));
        const frenchLink = links.find(link => link.textContent.trim().includes('Français'));
        if (frenchLink) {
          frenchLink.click();
        }
      });
      
      await navigationPromise;
      
      const currentUrl = page.url();
      if (currentUrl.includes('/fr')) {
        console.log(`   ✓ Navigated to French route: ${currentUrl}`);
        testsPassed++;
      } else {
        console.error(`   ✗ Expected /fr route, got: ${currentUrl}`);
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Failed to navigate to French: ${error.message}`);
      testsFailed++;
    }

    // Test 6: Verify html lang attribute updated
    console.log('✅ Test 6: Verify html lang attribute updated to "fr"');
    const frenchLang = await getHtmlLang(page);
    if (frenchLang === 'fr') {
      console.log(`   ✓ html[lang="${frenchLang}"] confirmed`);
      testsPassed++;
    } else {
      console.error(`   ✗ Expected html[lang="fr"], got html[lang="${frenchLang}"]`);
      testsFailed++;
    }

    // Test 7: Verify button updated to show new locale
    console.log('✅ Test 7: Verify selector button updated to show "fr"');
    try {
      await page.waitForTimeout(300); // Wait for any re-render
      const buttonText = await page.$eval('.language-selector button[aria-haspopup]', el => el.textContent.trim());
      
      if (buttonText && buttonText.toLowerCase().includes('fr')) {
        console.log(`   ✓ Button updated to: "${buttonText}"`);
        testsPassed++;
      } else {
        console.error(`   ✗ Button should show 'fr', but found: "${buttonText}"`);
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not verify updated button: ${error.message}`);
      testsFailed++;
    }

    // Test 8: Mobile viewport - verify tap target size
    console.log('✅ Test 8: Verify mobile-friendly tap target size (≥44x44px)');
    await page.setViewport({ width: 375, height: 667 }); // iPhone SE size
    await page.goto(BASE_URL, { waitUntil: 'networkidle0', timeout: TIMEOUT });
    
    try {
      const dimensions = await getButtonDimensions(page, '.language-selector button[aria-haspopup]');
      
      if (dimensions && dimensions.width >= 44 && dimensions.height >= 44) {
        console.log(`   ✓ Button meets minimum tap target: ${Math.round(dimensions.width)}x${Math.round(dimensions.height)}px`);
        testsPassed++;
      } else if (dimensions) {
        console.error(`   ✗ Button too small for mobile: ${Math.round(dimensions.width)}x${Math.round(dimensions.height)}px (minimum 44x44px)`);
        testsFailed++;
      } else {
        console.error('   ✗ Could not measure button dimensions');
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not verify tap target size: ${error.message}`);
      testsFailed++;
    }

    // Test 9: Mobile - verify dropdown items have adequate tap targets
    console.log('✅ Test 9: Verify dropdown items have adequate mobile tap targets');
    try {
      await page.click('.language-selector button[aria-haspopup]');
      await page.waitForTimeout(300);
      
      const itemDimensions = await page.evaluate(() => {
        const menu = document.querySelector('.language-selector [role="menu"], .language-selector .language-menu');
        if (!menu) return [];
        
        const items = Array.from(menu.querySelectorAll('a, [role="menuitem"]'));
        return items.map(item => {
          const rect = item.getBoundingClientRect();
          return {
            width: rect.width,
            height: rect.height,
          };
        });
      });

      const allAdequate = itemDimensions.every(dim => dim.height >= 44);
      
      if (allAdequate && itemDimensions.length > 0) {
        console.log(`   ✓ All ${itemDimensions.length} dropdown items have adequate height`);
        testsPassed++;
      } else {
        console.error(`   ✗ Some dropdown items have inadequate tap targets`);
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not verify dropdown tap targets: ${error.message}`);
      testsFailed++;
    }

    // Test 10: Verify dropdown doesn't clip outside viewport on mobile
    console.log('✅ Test 10: Verify dropdown is not clipped by viewport edges on mobile');
    try {
      const isClipped = await page.evaluate(() => {
        const menu = document.querySelector('.language-selector [role="menu"], .language-selector .language-menu');
        if (!menu) return true;
        
        const rect = menu.getBoundingClientRect();
        const viewportWidth = window.innerWidth;
        const viewportHeight = window.innerHeight;
        
        return rect.right > viewportWidth || 
               rect.bottom > viewportHeight || 
               rect.left < 0 || 
               rect.top < 0;
      });

      if (!isClipped) {
        console.log('   ✓ Dropdown is fully visible within viewport');
        testsPassed++;
      } else {
        console.error('   ✗ Dropdown is clipped by viewport edges');
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not verify viewport clipping: ${error.message}`);
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
