import requests

class DataPassApiClient:
    def __init__(self, client_id, client_secret, base_url='http://localhost:3000'):
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
            return token_data
        except requests.exceptions.RequestException as e:
            print(f"Error getting token: {e}")
            return None
    
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
            token_response = self.get_token()
            if not token_response:
                return None
        
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
    
    def get_demande(self, demande_id):
        """
        Get a specific demande (authorization request) by ID
        
        Args:
            demande_id (str): The ID of the demande to retrieve
            
        Returns:
            dict: The demande data or None if not found
        """
        return self._make_authenticated_request(f'/api/v1/demandes/{demande_id}') 