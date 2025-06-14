import os
import sys
import requests
from bs4 import BeautifulSoup


def process_beecrowd_cell(cell):
    """
    Processes a single <td> cell from the beecrowd examples table.
    It correctly handles line breaks and whitespace.
    """
    line_separator = "||LINE_BREAK||"

    content_block = cell.find('p')
    if not content_block:
        content_block = cell

    for br in content_block.find_all('br'):
        br.replace_with(line_separator)

    text_with_separator = content_block.get_text()
    lines = text_with_separator.split(line_separator)

    cleaned_lines = []
    for line in lines:
        cleaned_line = line.strip('\n').strip(' ')
        cleaned_lines.append(cleaned_line)

    return '\n'.join(cleaned_lines)


def scrape_beecrowd_problem(url: str):
    """
    Scrapes the first example input and output from a Beecrowd problem page,
    preserving internal whitespace.
    """
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()  # Raises an HTTPError for bad responses
    except requests.RequestException as e:
        raise Exception(f"Failed to fetch page: {e}")

    soup = BeautifulSoup(response.text, 'html.parser')

    tables = soup.find_all('table')
    if not tables:
        raise Exception("No example tables found.")

    first_data_row = tables[0].find('tbody').find('tr')
    if not first_data_row:
        raise Exception("No data row found in the example table.")

    columns = first_data_row.find_all('td')
    if len(columns) < 2:
        raise Exception("Could not find input and output columns.")

    input_text = process_beecrowd_cell(columns[0])
    output_text = process_beecrowd_cell(columns[1])

    return input_text, output_text


# Example usage
if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python beecrowd_importer.py <beecrowd_problem_id> <file_extension>")
        exit(1)
    else:
        bcid = 0
        try:
            bcid = int(sys.argv[1])
        except ValueError:
            print("Invalid problem ID. Please provide a numeric ID.")
            exit(1)
        url = f"https://www.beecrowd.com.br/repository/UOJ_{bcid}.html"

    input_text = ""
    output_text = ""
    try:
        input_text, output_text = scrape_beecrowd_problem(url)
    except Exception as e:
        print("Error:", str(e))
        exit(1)

    extension = sys.argv[2]
    if not extension.startswith('.'):
        print("Error: file extension must start with a dot (e.g., .py, .cpp).")
        sys.exit(1)
    filename = f"{bcid}{extension}"
    # Find the index of the first dot (.)
    dot_index = filename.find('.')
    if dot_index == -1:
        print("Error: filename must contain a dot.")
        sys.exit(1)

    basename = filename[:dot_index]

    input_file = f"./tests/{basename}.in"
    expected_output_file = f"./tests/{basename}.exout"
    solution_file = f"./solutions/{filename}"

    # Create the files if they don't exist
    for path in [input_file, expected_output_file, solution_file]:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        open(path, 'a').close()  # touch equivalent

    print("Created files:")
    print(input_file)
    print(expected_output_file)
    print(solution_file)

    print("Writing input and expected output to files...")
    with open(input_file, 'w', encoding='utf-8') as f:
        f.write(input_text)
    with open(expected_output_file, 'w', encoding='utf-8') as f:
        f.write(output_text)
    print("Done")
