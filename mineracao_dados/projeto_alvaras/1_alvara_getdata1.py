from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from bs4 import BeautifulSoup
import json
import os
from time import sleep
from tqdm import tqdm

# Define the output directory
OUTPUT_DIR = '/home/alceu/Documents/data/alvaras'

def ensure_output_directory():
    """Create the output directory if it doesn't exist."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

def extract_table_data(table):
    """Extract data from table with headers and values."""
    if not table:
        return {}
    headers = [th.get_text(strip=True) for th in table.find_all('tr')[0].find_all('td')]
    values = [td.get_text(strip=True) for td in table.find_all('tr')[1].find_all('td')]
    return dict(zip(headers, values))

def get_last_processed():
    """Find the last processed permit number from existing JSON files."""
    if not os.path.exists(OUTPUT_DIR):
        return 1
    files = [f for f in os.listdir(OUTPUT_DIR) if f.endswith('.json')]
    if not files:
        return 1
    return max(int(f.split('.')[0]) for f in files)

def get_alvara_construcao(browser, documento):
    """Extract complete permit data from webpage."""
    try:
        record_url = 'http://www2.curitiba.pr.gov.br/gtm/pmat_consultardadosalvaraconstrucao/DetalheAlvaraConstrucao.aspx?strNrDocumento={}&rdoTipoPesquisa=0'
        browser.get(record_url.format(documento))
        browser.switch_to.default_content()

        # Parse DIV_1 data
        result = browser.find_element(By.ID, 'DIV_1')
        soup = BeautifulSoup(result.get_attribute('outerHTML'), 'html.parser')
        div1 = {}
        for tr in soup.find_all('tr'):
            tds = tr.find_all('td')
            if len(tds) == 4:
                main_key = tds[0].get_text(strip=True).replace('\xa0', ' ')
                sub_object = {
                    "Nome": tds[1].get_text(strip=True),
                    tds[2].get_text(strip=True).replace('\xa0', ' '): tds[3].get_text(strip=True)
                }
                div1[main_key] = sub_object
            elif len(tds) == 2:
                key = tds[0].get_text(strip=True).replace('\xa0', ' ')
                value = tds[1].get_text(strip=True)
                div1[key] = value

        # Parse DIV_2 data
        result = browser.find_element(By.ID, 'DIV_2')
        soup = BeautifulSoup(result.get_attribute('outerHTML'), 'html.parser')
        div2 = {}
        for tr in soup.find_all('tr'):
            tds = tr.find_all('td')
            if len(tds) == 2:
                key = tds[0].get_text(strip=True).replace('\xa0', ' ')
                value = tds[1].get_text(strip=True)
                div2[key] = value

        # Parse DIV_3 data
        result = browser.find_element(By.ID, 'DIV_3')
        soup = BeautifulSoup(result.get_attribute('outerHTML'), 'html.parser')
        div3 = {}

        # Extract DadosLote
        dados_lote_table = soup.find('table', {'id': 'dgDadosLote'})
        div3['DadosLote'] = extract_table_data(dados_lote_table)

        # Extract first block data
        for tr in soup.find_all('table')[2].find_all('table')[3].find_all('tr'):
            tds = tr.find_all('td')
            if len(tds) == 5:
                div3[tds[0].get_text(strip=True).replace('\xa0', ' ')] = tds[1].get_text(strip=True).replace('\xa0', ' ')
                div3[tds[3].get_text(strip=True).replace('\xa0', ' ')] = tds[4].get_text(strip=True).replace('\xa0', ' ')
            if len(tds) == 3:
                key = tds[0].get_text(strip=True).replace('\xa0', ' ')
                value = tds[1].get_text(strip=True)
                div3[key] = value

        # Extract DadosEdificacao
        dados_edificacao_table = soup.find('table', {'id': 'dgDadosEdificacao'})
        div3['DadosEdificacao'] = extract_table_data(dados_edificacao_table)

        # Extract Areas Computaveis and Nao Computaveis
        div3['Áreas Computáveis (m2)'] = {}
        div3['Áreas Não Computáveis (m2)'] = {}

        for tr in soup.find_all('table')[2].find_all('table')[6].find_all('tr')[1:6]:
            tds = tr.find_all('td')
            div3['Áreas Computáveis (m2)'][tds[0].get_text(strip=True).replace('\xa0', ' ')] = tds[1].get_text(strip=True).replace('\xa0', ' ')
            div3['Áreas Não Computáveis (m2)'][tds[3].get_text(strip=True).replace('\xa0', ' ')] = tds[4].get_text(strip=True).replace('\xa0', ' ')

        for tr in soup.find_all('table')[2].find_all('table')[6].find_all('tr')[6:]:
            tds = tr.find_all('td')
            if len(tds) >= 5:
                div3['Áreas Não Computáveis (m2)'][tds[3].get_text(strip=True).replace('\xa0', ' ')] = tds[4].get_text(strip=True).replace('\xa0', ' ')

        # Extract Areas de Recreacao, Outras Areas, and Parametros do Zoneamento
        div3['Áreas De Recreção (m2)'] = {}
        div3['Outras Áreas (m2)'] = {}
        div3['Parâmetros Do Zoneamento'] = {}

        # Areas de Recreacao
        for tr in soup.find_all('table')[2].find_all('table')[7].find_all('tr'):
            tds = tr.find_all('td')
            if len(tds) == 5:
                div3['Áreas De Recreção (m2)'][tds[0].get_text(strip=True).replace('\xa0', ' ')] = tds[1].get_text(strip=True).replace('\xa0', ' ')
                div3['Áreas De Recreção (m2)'][tds[3].get_text(strip=True).replace('\xa0', ' ')] = tds[4].get_text(strip=True).replace('\xa0', ' ')
            if len(tds) == 3:
                key = tds[0].get_text(strip=True).replace('\xa0', ' ')
                value = tds[1].get_text(strip=True)
                div3['Áreas De Recreção (m2)'][key] = value

        # Outras Areas
        for tr in soup.find_all('table')[2].find_all('table')[8].find_all('tr'):
            tds = tr.find_all('td')
            if len(tds) == 5:
                div3['Outras Áreas (m2)'][tds[0].get_text(strip=True).replace('\xa0', ' ')] = tds[1].get_text(strip=True).replace('\xa0', ' ')
                div3['Outras Áreas (m2)'][tds[3].get_text(strip=True).replace('\xa0', ' ')] = tds[4].get_text(strip=True).replace('\xa0', ' ')
            if len(tds) == 3:
                key = tds[0].get_text(strip=True).replace('\xa0', ' ')
                value = tds[1].get_text(strip=True)
                div3['Outras Áreas (m2)'][key] = value

        # Parametros do Zoneamento
        for tr in soup.find_all('table')[2].find_all('table')[9].find_all('tr'):
            tds = tr.find_all('td')
            if len(tds) == 5:
                div3['Parâmetros Do Zoneamento'][tds[0].get_text(strip=True).replace('\xa0', ' ')] = tds[1].get_text(strip=True).replace('\xa0', ' ')
                div3['Parâmetros Do Zoneamento'][tds[3].get_text(strip=True).replace('\xa0', ' ')] = tds[4].get_text(strip=True).replace('\xa0', ' ')
            if len(tds) == 3:
                key = tds[0].get_text(strip=True).replace('\xa0', ' ')
                value = tds[1].get_text(strip=True)
                div3['Parâmetros Do Zoneamento'][key] = value

        # Combine all data
        alvara = div1
        alvara.update(div2)
        alvara.update(div3)
        return alvara

    except Exception as e:
        print(f"\nError processing document {documento}: {str(e)}")
        return None

def main():
    # Ensure the output directory exists
    ensure_output_directory()

    start_num = get_last_processed()
    end_num = 406000
    
    print(f"Starting from permit number: {start_num}")
    print(f"Saving files to: {OUTPUT_DIR}")
    
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    
    browser = webdriver.Chrome(options=chrome_options)
    
    try:
        for doc_num in tqdm(range(start_num, end_num + 1), desc="Processing permits"):
            output_file = os.path.join(OUTPUT_DIR, f"{doc_num}.json")
            
            if os.path.exists(output_file):
                continue
                
            data = get_alvara_construcao(browser, str(doc_num))
            if data:
                with open(output_file, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
                
            # Prevent overwhelming the server
            sleep(1)
            
    except KeyboardInterrupt:
        print("\nScript interrupted by user. Progress saved.")
    except Exception as e:
        print(f"\nUnexpected error: {str(e)}")
    finally:
        browser.quit()

if __name__ == "__main__":
    main()