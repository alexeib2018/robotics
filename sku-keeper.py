import requests
session = requests.Session()

def init():

    postData = {
        'name': 'yourusername',
        'pass': 'yourpassword',
        'form_id': 'user_login_block',
        'op': 'Log in'
    }

    loginUrl = 'https://www.sku-keeper.com/api'
    response = session.post(loginUrl, data=postData)
    print response

def lightDevice(devID,line1,line2):
    newUrl = 'https://www.sku-keeper.com/api/'+devID+'/message/'+line1+'/'+line2+'/15,c5,4/10'
    response = session.get(newUrl)
    print response


init()
lightDevice('E8D787:72D9D7','hell','yeah')
lightDevice('FFFE81:A42B35','hell','yeah')
lightDevice('FAAD4B:8E336A','hell','yeah')
lightDevice('FF754A:E24C16','hell','yeah')
lightDevice('FB9915:C956FC','hell','yeah')
