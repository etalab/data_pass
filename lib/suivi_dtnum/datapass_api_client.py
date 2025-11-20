import requests

class DataPassApiClient:
    BASE_URL = 'http://localhost:3000'
    # BASE_URL = 'https://sandbox.v2.datapass.api.gouv.fr'

    def __init__(self, client_id, client_secret, base_url=BASE_URL):
        self.client_id = client_id
        self.client_secret = client_secret
        self.base_url = base_url
        self.access_token = None

    def get_token(self):
        """Get OAuth token from DataPass API"""
        url = f"{self.base_url}/api/oauth/token"
        
        data = {
            'grant_type': 'client_credentials',
            'client_id': self.client_id,
            'client_secret': self.client_secret
        }
        
        try:
            response = requests.post(url, data=data)
            response.raise_for_status()
            token_data = response.json()
            self.access_token = token_data['access_token']
            print("\nAPI token obtained successfully from datapass")
            return token_data

        except requests.exceptions.RequestException as e:
            print(f"Error getting token: {e}")
            raise e
    
    def _make_authenticated_request(self, endpoint, method='get', data=None, params=None):
        """
        Make an authenticated request to the DataPass API
        
        Args:
            endpoint (str): API endpoint path (without base URL)
            method (str): HTTP method ('get', 'post', 'patch', etc.)
            data (dict): Request payload for POST/PATCH requests
            params (dict): Query parameters
            
        Returns:
            dict: JSON response or None if error
        """
        if not self.access_token:
            self.get_token()
        
        url = f"{self.base_url}{endpoint}"
        
        headers = {
            'Authorization': f'Bearer {self.access_token}'
        }
        
        try:
            request_method = getattr(requests, method.lower())
            response = request_method(url, headers=headers, json=data, params=params)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error making {method.upper()} request to {endpoint}: {e}")
            return None

    def get_demandes(self, limit=10, offset=0, states=None):
        """
        Get all demandes (authorization requests) from DataPass API
        
        Args:
            limit (int): Maximum number of demandes to retrieve (1-100)
            offset (int): Number of demandes to skip
            states (str or list): Filter demandes by state(s)
            
        Returns:
            list: List of demandes or None if error
        """
        params = {
            'limit': limit,
            'offset': offset
        }
        
        if states:
            params['state[]'] = states
            
        return self._make_authenticated_request('/api/v1/demandes', params=params)
    

    def get_all_demandes(self):
        print("Iterating on all demandes from datapass...")
        
        all_demandes = []
        offset = 0
        limit = 1000
        
        while True:
            demandes_page = self.get_demandes(limit=limit, offset=offset)
            if not demandes_page or len(demandes_page) == 0:
                break
                
            all_demandes.extend(demandes_page)
            print(f"Retrieved {len(demandes_page)} demandes (offset: {offset})")
            
            if len(demandes_page) < limit:
                break
                
            offset += limit
        
        print(f"Total demandes retrieved: {len(all_demandes)}")
        return all_demandes
