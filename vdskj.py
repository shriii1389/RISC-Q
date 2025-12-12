import numpy as np
import matplotlib.pyplot as plt

# Step 1: Parse the data from the provided input
def parse_data(file_path):
    """
    Reads data from a text file and extracts resonance series.
    Each resonance series is separated by an empty line.
    """
    with open(file_path, 'r') as file:
        lines = file.readlines()

    data = []
    current_series = []
    for line in lines:
        if line.strip():  # Non-empty line
            if "resonance" in line:  # Skip header lines
                continue
            current_series.append(list(map(float, line.strip().split(','))))
        else:  # Empty line indicates the end of a resonance series
            if current_series:
                data.append(np.array(current_series))
                current_series = []
    if current_series:  # Append the last series
        data.append(np.array(current_series))
    return data

# Step 2: Plot each resonance series
def plot_resonance_series(data):
    """
    Plots each resonance series on a separate plot.
    """
    for i, series in enumerate(data):
        indices = series[:, 0]  # First column: indices
        y_values = series[:, 1]  # Second column: Y-values
        
        plt.figure(figsize=(8, 5))
        plt.plot(indices, y_values, marker='o', linestyle='-', label=f'Resonance {i + 1}')
        plt.title(f'Resonance {i + 1}')
        plt.xlabel('Index')
        plt.ylabel('Y')
        plt.grid()
        plt.legend()
        plt.tight_layout()
        plt.show()

# File path to your data
file_path = r"C:\Users\shrih\Desktop\COD_Project\your_text.txt"  # Replace with the path to your file

# Step 3: Load and plot the data
resonance_data = parse_data(file_path)
plot_resonance_series(resonance_data)
