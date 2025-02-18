import os
import datetime

def rename_files_with_date(filenames):
    """Renames files in a directory by adding the current date to their names.

    Args:
        directory: The path to the directory containing the files to rename.
    """
    for filename in filenames:
        if os.path.isfile(filename):
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            new_filename = f"{os.path.splitext(filename)[0]}_{timestamp}{os.path.splitext(filename)[1]}"
            os.rename(filename, new_filename)
            print(f"Renamed '{filename}' to '{new_filename}'")

# Example usage:
filenames = ['./logs/dbt.log','./target/run_results.json']  # Replace with the actual directory path
rename_files_with_date(filenames)
