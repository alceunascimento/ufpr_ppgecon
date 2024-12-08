import requests
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chromium.options import ChromiumOptions
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException
import time
import logging
from typing import Optional, List

# Set up detailed logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class BCBStatuteScraper:
    def __init__(self, headless: bool = True):
        """Initialize the scraper with Chromium webdriver configuration for Linux."""
        self.options = ChromiumOptions()
        if headless:
            self.options.add_argument("--headless=new")  # Updated headless argument
        
        # Linux-specific options
        self.options.add_argument("--no-sandbox")
        self.options.add_argument("--disable-dev-shm-usage")
        self.options.add_argument("--disable-gpu")
        self.options.add_argument("--window-size=1920,1080")  # Set window size
        self.options.add_argument("--disable-extensions")
        self.options.add_argument("--dns-prefetch-disable")
        self.options.add_argument("--disable-features=VizDisplayCompositor")
        
        # Add user agent
        self.options.add_argument("user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
        
        try:
            self.driver = webdriver.Chrome(options=self.options)
            self.driver.implicitly_wait(20)  # Increased implicit wait
            logger.info("Successfully initialized Chromium WebDriver")
        except Exception as e:
            logger.error(f"Failed to initialize Chromium WebDriver: {str(e)}")
            raise

    def wait_for_page_load(self):
        """Wait for the page to be fully loaded."""
        try:
            WebDriverWait(self.driver, 10).until(
                lambda driver: driver.execute_script('return document.readyState') == 'complete'
            )
        except Exception as e:
            logger.warning(f"Page load wait warning: {str(e)}")

    def scrape_statute(self, url: str) -> Optional[str]:
        """
        Scrapes a single statute from the given URL.
        """
        try:
            logger.info(f"Scraping URL: {url}")
            self.driver.get(url)
            
            # Wait for initial page load
            self.wait_for_page_load()
            logger.debug("Initial page load complete")
            
            # Wait for JavaScript to execute
            time.sleep(5)  # Add explicit wait for JavaScript
            logger.debug("Waited for JavaScript execution")
            
            # Try multiple selectors
            selectors = [
                ".corpoNormativo",
                "div.corpoNormativo",
                "[class*='corpoNormativo']"
            ]
            
            statute_element = None
            for selector in selectors:
                try:
                    wait = WebDriverWait(self.driver, 30)  # Increased timeout
                    statute_element = wait.until(
                        EC.presence_of_element_located((By.CSS_SELECTOR, selector))
                    )
                    if statute_element:
                        logger.debug(f"Found element with selector: {selector}")
                        break
                except:
                    logger.debug(f"Selector not found: {selector}")
                    continue
            
            if not statute_element:
                logger.error("Could not find statute content with any selector")
                # Get page source for debugging
                logger.debug(f"Page source: {self.driver.page_source[:500]}...")
                return None
            
            # Get the HTML content
            statute_html = statute_element.get_attribute('innerHTML')
            logger.debug(f"Retrieved HTML content length: {len(statute_html)}")
            
            # Parse with BeautifulSoup
            soup = BeautifulSoup(statute_html, 'html.parser')
            
            # Remove style attributes and normalize spacing
            for tag in soup.find_all(True):
                if 'style' in tag.attrs:
                    del tag['style']
            
            statute_text = soup.get_text(separator='\n', strip=True)
            logger.info(f"Successfully scraped content, length: {len(statute_text)}")
            
            return statute_text
            
        except TimeoutException as te:
            logger.error(f"Timeout waiting for content to load: {url}")
            logger.debug(f"Timeout exception details: {str(te)}")
            return None
        except Exception as e:
            logger.error(f"Error scraping URL {url}: {str(e)}")
            logger.debug(f"Exception details: {str(e)}", exc_info=True)
            return None

    def scrape_multiple_statutes(self, urls: List[str], delay: float = 2.0) -> dict:
        """
        Scrapes multiple statutes with delay between requests.
        """
        results = {}
        
        for i, url in enumerate(urls, 1):
            logger.info(f"Processing URL {i} of {len(urls)}")
            content = self.scrape_statute(url)
            results[url] = content
            
            if i < len(urls):
                logger.debug(f"Waiting {delay} seconds before next request")
                time.sleep(delay)
            
        return results

    def save_to_files(self, results: dict, base_filename: str = "statute"):
        """
        Saves the scraped statutes to individual text files.
        """
        for i, (url, content) in enumerate(results.items(), 1):
            if content:
                filename = f"{base_filename}_{i}.txt"
                try:
                    with open(filename, 'w', encoding='utf-8') as f:
                        f.write(f"Source URL: {url}\n\n")
                        f.write(content)
                    logger.info(f"Saved statute to {filename}")
                except Exception as e:
                    logger.error(f"Error saving to file {filename}: {str(e)}")

    def close(self):
        """Closes the browser and cleans up resources."""
        if hasattr(self, 'driver'):
            try:
                self.driver.quit()
                logger.info("Successfully closed Chromium WebDriver")
            except Exception as e:
                logger.error(f"Error closing Chromium WebDriver: {str(e)}")

# Example usage
if __name__ == "__main__":
    # List of URLs to scrape
    urls = [
        "https://www.bcb.gov.br/estabilidadefinanceira/exibenormativo?tipo=Instrução%20Normativa%20BCB&numero=243",
    ]
    
    scraper = None
    try:
        # Initialize scraper
        scraper = BCBStatuteScraper(headless=True)
        
        # Scrape statutes
        results = scraper.scrape_multiple_statutes(urls)
        
        # Save results to files
        scraper.save_to_files(results)
        
        # Print summary
        print("\nScraping Summary:")
        for url, content in results.items():
            status = "Success" if content else "Failed"
            print(f"{status}: {url}")
            
    except Exception as e:
        logger.error(f"An error occurred during execution: {str(e)}")
        
    finally:
        # Clean up
        if scraper:
            scraper.close()