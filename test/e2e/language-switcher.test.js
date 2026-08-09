#!/usr/bin/env node
/* eslint-disable no-console */

/**
 * Language Switcher Test
 * Tests homepage loading with English locale and language switching to French
 * 
 * Requirements:
 * - Verify initial page loads with html[lang="en"]
 * - Verify English headings are present
 * - Locate and interact with language selector
 * - Switch to French locale
 * - Verify page updates to html[lang="fr"]
 * - Verify French headings are displayed
 */

const puppeteer = require('puppeteer');

// Configuration
const BASE_URL = process.env.TEST_BASE_URL || 'http://localhost:3000';
const ROOT_PATH = process.env.TEST_ROOT_PATH || '/';
const SEARCH_PATH = process.env.TEST_SEARCH_PATH || '/en/searches/new';
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

function buildUrl(path) {
  return new URL(path, BASE_URL).toString();
}

/**
 * Main test function
 */
async function runTest() {
  console.log('🚀 Starting Language Switcher Test');
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
    await page.goto(buildUrl(ROOT_PATH), { waitUntil: 'networkidle0', timeout: TIMEOUT });
    
    const initialLang = await getHtmlLang(page);
    if (initialLang === 'en') {
      console.log(`   ✓ html[lang="${initialLang}"] detected`);
      testsPassed++;
    } else {
      console.error(`   ✗ Expected html[lang="en"], but got html[lang="${initialLang}"]`);
      testsFailed++;
    }

    await page.goto(buildUrl(SEARCH_PATH), { waitUntil: 'networkidle0', timeout: TIMEOUT });

    // Test 2: Verify English search headings are present
    console.log('✅ Test 2: Verify English search headings are present');
    try {
      const englishHeroHeading = await page.$eval('h1', el => el.textContent);
      const englishSectionHeading = await page.$eval('h2', el => el.textContent);
      if (
        englishHeroHeading &&
        englishHeroHeading.includes('COFFEE NEAR YOU!') &&
        englishSectionHeading &&
        englishSectionHeading.includes('New Search')
      ) {
        console.log(`   ✓ Found English hero heading: "${englishHeroHeading.trim()}"`);
        console.log(`   ✓ Found English translated heading: "${englishSectionHeading.trim()}"`);
        testsPassed++;
      } else {
        console.error(
          `   ✗ English headings not found or incorrect. Found h1: "${englishHeroHeading}", h2: "${englishSectionHeading}"`,
        );
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not find heading element: ${error.message}`);
      testsFailed++;
    }

    // Test 3: Verify English search placeholder
    console.log('✅ Test 3: Verify English search placeholder');
    try {
      const placeholder = await page.$eval('input[name="search[query]"]', el => el.getAttribute('placeholder'));
      if (placeholder && placeholder.includes('Search for coffee shops')) {
        console.log(`   ✓ Found English placeholder: "${placeholder}"`);
        testsPassed++;
      } else {
        console.error(`   ✗ English placeholder not found or incorrect. Found: "${placeholder}"`);
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not find search input: ${error.message}`);
      testsFailed++;
    }

    // Test 4: Locate and interact with French language selector
    console.log('✅ Test 4: Locate and click French language selector');
    try {
      // Wait for footer to be present
      await page.waitForSelector('footer .footer-language', { timeout: TIMEOUT });
      
      // Find the French language link
      const frenchLinkFound = await page.evaluate(() => {
        const links = Array.from(document.querySelectorAll('footer .footer-language a'));
        const frenchLink = links.find(link => link.textContent.trim() === 'Français');
        return !!frenchLink;
      });

      if (frenchLinkFound) {
        console.log('   ✓ Found French language selector link');
        testsPassed++;
      } else {
        console.error('   ✗ French language selector link not found');
        testsFailed++;
        throw new Error('French link not found');
      }

      await Promise.all([
        page.waitForNavigation({ waitUntil: 'networkidle0', timeout: TIMEOUT }),
        page.evaluate(() => {
          const links = Array.from(document.querySelectorAll('footer .footer-language a'));
          const frenchLink = links.find(link => link.textContent.trim() === 'Français');
          if (frenchLink) {
            frenchLink.click();
          }
        }),
      ]);
      console.log('   ✓ Clicked French language selector');

    } catch (error) {
      console.error(`   ✗ Failed to interact with French language selector: ${error.message}`);
      testsFailed++;
    }

    // Test 5: Verify page updates to French locale
    console.log('✅ Test 5: Verify page updates to html[lang="fr"]');
    const frenchLang = await getHtmlLang(page);
    if (frenchLang === 'fr') {
      console.log(`   ✓ html[lang="${frenchLang}"] detected after language switch`);
      testsPassed++;
    } else {
      console.error(`   ✗ Expected html[lang="fr"], but got html[lang="${frenchLang}"]`);
      testsFailed++;
    }

    // Test 6: Verify French search headings are displayed
    console.log('✅ Test 6: Verify French search headings are displayed');
    try {
      const frenchHeroHeading = await page.$eval('h1', el => el.textContent);
      const frenchSectionHeading = await page.$eval('h2', el => el.textContent);
      if (
        frenchHeroHeading &&
        frenchHeroHeading.includes('COFFEE NEAR YOU!') &&
        frenchSectionHeading &&
        frenchSectionHeading.includes('Nouvelle recherche')
      ) {
        console.log(`   ✓ Found French hero heading: "${frenchHeroHeading.trim()}"`);
        console.log(`   ✓ Found French translated heading: "${frenchSectionHeading.trim()}"`);
        testsPassed++;
      } else {
        console.error(
          `   ✗ French headings not found or incorrect. Found h1: "${frenchHeroHeading}", h2: "${frenchSectionHeading}"`,
        );
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not find heading element: ${error.message}`);
      testsFailed++;
    }

    // Test 7: Verify French search placeholder
    console.log('✅ Test 7: Verify French search placeholder');
    try {
      const placeholder = await page.$eval('input[name="search[query]"]', el => el.getAttribute('placeholder'));
      if (placeholder && placeholder.includes('Rechercher des cafés')) {
        console.log(`   ✓ Found French placeholder: "${placeholder}"`);
        testsPassed++;
      } else {
        console.error(`   ✗ French placeholder not found or incorrect. Found: "${placeholder}"`);
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not find search input: ${error.message}`);
      testsFailed++;
    }

    // Test 8: Verify active language link styling
    console.log('✅ Test 8: Verify active language link has correct styling');
    try {
      const activeClass = await page.evaluate(() => {
        const links = Array.from(document.querySelectorAll('footer .footer-language a'));
        const frenchLink = links.find(link => link.textContent.trim() === 'Français');
        return frenchLink ? frenchLink.className : null;
      });

      if (activeClass && activeClass.includes('language-nav__link--active')) {
        console.log(`   ✓ French link has active class: "${activeClass}"`);
        testsPassed++;
      } else {
        console.error(`   ✗ French link missing active class. Found: "${activeClass}"`);
        testsFailed++;
      }
    } catch (error) {
      console.error(`   ✗ Could not verify active class: ${error.message}`);
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
