"""Example of Python client calling Knowledge Graph Search API."""
import json
import urllib

api_key = 'AIzaSyApzyzMD2JgBPQxpT0n7m2aHIwMX_iasCw'
query = 'Iron Maiden'
service_url = 'https://kgsearch.googleapis.com/v1/entities:search'
params = {
    'query': query,
    'limit': 10,
    'indent': True,
    'key': api_key,
}
url = service_url + '?' + urllib.urlencode(params)
response = json.loads(urllib.urlopen(url).read())
for element in response['itemListElement']:
  print element['result']['name'] + ' (' + str(element['resultScore']) + ')'

print json.dumps(response,indent=4,sort_keys=True)

