#!/usr/bin/env python3
"""
Standalone script to add organization names to dataservices using the data.gouv.fr API.

This script reads a JSON file containing dataservices, fetches organization information
from the data.gouv.fr API for each dataservice, and adds the organization name to each entry.
"""

import json
import sys
import time
from pathlib import Path
from typing import Dict, List, Optional

try:
    import requests
except ImportError:
    print("Error: 'requests' library is required. Install it with: pip install requests")
    sys.exit(1)

API_BASE_URL = "https://www.data.gouv.fr/api/1"
INPUT_FILE = Path(__file__).parent / "dataservices_with_api_gouv_access_enhanced_with_props.json"
OUTPUT_FILE = Path(__file__).parent / "dataservices_with_api_gouv_access_enhanced_with_props.json"


def fetch_dataservice(dataservice_id: str) -> Optional[Dict]:
    """
    Fetch a single dataservice from the data.gouv.fr API.
    
    Args:
        dataservice_id: The ID of the dataservice to fetch
        
    Returns:
        The dataservice data as a dictionary, or None if there was an error
    """
    url = f"{API_BASE_URL}/dataservices/{dataservice_id}/"
    
    retries = 0
    max_retries = 5
    
    while retries < max_retries:
        try:
            response = requests.get(url, headers={"Accept": "application/json"}, timeout=30)
            
            if response.status_code == 200:
                return response.json()
            elif response.status_code == 404:
                print(f"  Warning: Dataservice {dataservice_id} not found (404)")
                return None
            else:
                print(f"  Warning: Unexpected status code {response.status_code} for dataservice {dataservice_id}")
                if retries < max_retries - 1:
                    time.sleep(1)
                    retries += 1
                    continue
                return None
                
        except requests.exceptions.RequestException as e:
            retries += 1
            if retries < max_retries:
                print(f"  Warning: Error fetching dataservice {dataservice_id}: {e}. Retrying...")
                time.sleep(1)
            else:
                print(f"  Error: Failed to fetch dataservice {dataservice_id} after {max_retries} retries: {e}")
                return None
    
    return None


def extract_organization_name(dataservice_data: Dict) -> Optional[str]:
    """
    Extract the organization name from a dataservice API response.
    
    Args:
        dataservice_data: The dataservice data from the API
        
    Returns:
        The organization name, or None if not found
    """
    organization = dataservice_data.get("organization")
    
    if organization and isinstance(organization, dict):
        # The organization object in the dataservice response contains the name directly
        org_name = organization.get("name")
        if org_name:
            return org_name
    
    return None


def main():
    """Main function to process dataservices and add organization names."""
    
    # Read the input JSON file
    if not INPUT_FILE.exists():
        print(f"Error: Input file not found: {INPUT_FILE}")
        sys.exit(1)
    
    print(f"Reading dataservices from: {INPUT_FILE}")
    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        dataservices = json.load(f)
    
    if not isinstance(dataservices, list):
        print("Error: Input file must contain a JSON array")
        sys.exit(1)
    
    print(f"Found {len(dataservices)} dataservices to process")
    print("-" * 80)
    
    # Process each dataservice
    updated_count = 0
    error_count = 0
    
    for i, dataservice in enumerate(dataservices, 1):
        dataservice_id = dataservice.get("id")
        title = dataservice.get("title", "Unknown")
        
        if not dataservice_id:
            print(f"{i}. Skipping entry without ID: {title}")
            error_count += 1
            continue
        
        # Check if organization_name already exists
        if "organization_name" in dataservice:
            print(f"{i}. {title} - Organization name already exists: {dataservice['organization_name']}")
            continue
        
        print(f"{i}. Processing: {title} (ID: {dataservice_id})")
        
        # Fetch dataservice details from API
        dataservice_data = fetch_dataservice(dataservice_id)
        
        if not dataservice_data:
            print(f"  Error: Could not fetch dataservice data")
            error_count += 1
            continue
        
        # Extract organization name
        org_name = extract_organization_name(dataservice_data)
        
        if org_name:
            dataservice["organization_name"] = org_name
            print(f"  ✓ Added organization: {org_name}")
            updated_count += 1
        else:
            print(f"  ⚠ No organization name found")
            dataservice["organization_name"] = None
            error_count += 1
        
        # Be nice to the API - add a small delay between requests
        time.sleep(0.5)
    
    print("-" * 80)
    print(f"\nProcessing complete!")
    print(f"  Updated: {updated_count}")
    print(f"  Errors/Missing: {error_count}")
    print(f"  Total: {len(dataservices)}")
    
    # Write the updated data back to the file
    print(f"\nWriting updated data to: {OUTPUT_FILE}")
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(dataservices, f, ensure_ascii=False, indent=2)
    
    print("Done!")


if __name__ == "__main__":
    main()

