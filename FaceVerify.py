import requests
import matplotlib.pyplot as plt
from PIL import Image
from matplotlib import patches
from io import BytesIO
import os
import Config as cnfg
import threading
import time
import urllib.parse as urlparse

def face_compare(id_1, id_2, api_url):
    """ Determine if two faceIDs are for the same person
    Args:
        id_1: faceID for person 1
        id_2: faceID for person 2
        api_url: API end point from Cognitive services
        show_face_id: If True, display the first 6 characters of the faceID

    Returns:
        json response: Full json data returned from the API call

    """
    headers = {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': subscription_key
    }

    body = {"faceId1": id_1, "faceId2": id_2}

    params = {}
    response = requests.post(api_url,
                            params=params,
                            headers=headers,
                            json=body)
    return response.json()
    
def annotate_image(image_url, subscription_key, api_url, show_face_id=False):
    """ Helper function for Microsoft Azure face detector.

    Args:
        image_url: Can be a remote http://  or file:// url pointing to an image less then 10MB
        subscription_key: Cognitive services generated key
        api_url: API end point from Cognitive services
        show_face_id: If True, display the first 6 characters of the faceID

    Returns:
        figure: matplotlib figure that contains the image and boxes around the faces with their age and gender
        json response: Full json data returned from the API call

    """

    # The default header must include the sunbscription key
    headers = {'Ocp-Apim-Subscription-Key': subscription_key}

    params = {
        'returnFaceId': 'true',
        'returnFaceLandmarks': 'false',
        'returnFaceAttributes': 'age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur,exposure,noise',
    }

    # Figure out if this is a local file or url
    parsed_url = urlparse(image_url)
    if parsed_url.scheme == 'file':
        image_data = open(parsed_url.path, "rb").read()

        # When making the request, we need to add a Content-Type Header
        # and pass data instead of a url
        headers['Content-Type']='application/octet-stream'
        response = requests.post(api_url, params=params, headers=headers, data=image_data)

        # Open up the image for plotting
        image = Image.open(parsed_url.path)
    else:
        # Pass in the URL to the API
        response = requests.post(api_url, params=params, headers=headers, json={"url": image_url})
        image_file = BytesIO(requests.get(image_url).content)
        image = Image.open(image_file)

    faces = response.json()

    fig, ax = plt.subplots(figsize=(10,10))

    ax.imshow(image, alpha=0.6)
    for face in faces:
        fr = face["faceRectangle"]
        fa = face["faceAttributes"]
        origin = (fr["left"], fr["top"])
        p = patches.Rectangle(origin, fr["width"],
                            fr["height"], fill=False, linewidth=2, color='b')
        ax.axes.add_patch(p)
        ax.text(origin[0], origin[1], "%s, %d"%(fa["gender"].capitalize(), fa["age"]),
                fontsize=16, weight="bold", va="bottom")

        if show_face_id:
            ax.text(origin[0], origin[1]+fr["height"], "%s"%(face["faceId"][:5]),
            fontsize=12, va="bottom")
    ax.axis("off")

    # Explicitly closing image so it does not show in the notebook
    plt.close()
    return fig, faces
    
def image_processing(image_path, subscription_key, api_url):
    image_data = open(image_path, "rb")
    
    headers = {'Content-Type':'application/octet-stream',
           'Ocp-Apim-Subscription-Key': subscription_key}
    params = {
    'returnFaceId': 'true',
    'returnFaceLandmarks': 'true',
    'returnFaceAttributes': 'age,gender,headPose,smile,facialHair,glasses,emotion'
    }

    response = requests.post(api_url, params=params, headers=headers, data=image_data)
    response.raise_for_status()
    face = response.json()
    return face

def ModifiedImagePath(image_path):
    if image_path.startswith("http://"):
        path = image_path
    else:
        path = "file://" + image_path
    return path

def ImageProcessingAnnotateCombo(image_path, subscription_key, api_url, show_face_id = False):
    image_data = open(image_path, "rb")
    
    headers = {'Content-Type':'application/octet-stream',
           'Ocp-Apim-Subscription-Key': subscription_key}
    params = {
    'returnFaceId': 'true',
    'returnFaceLandmarks': 'true',
    'returnFaceAttributes': 'age,gender,headPose,smile,facialHair,glasses,emotion'
    }
    response = requests.post(api_url, params=params, headers=headers, data=image_data)
    response.raise_for_status()
    faces = response.json()
    '''
    # Figure out if this is a local file or url
    parsed_url = urlparse(image_url)
    if parsed_url.scheme == 'file':
        image_data = open(parsed_url.path, "rb").read()

        # When making the request, we need to add a Content-Type Header
        # and pass data instead of a url
        headers['Content-Type']='application/octet-stream'
        response = requests.post(api_url, params=params, headers=headers, data=image_data)

        # Open up the image for plotting
        image = Image.open(parsed_url.path)
    else:
        # Pass in the URL to the API
        response = requests.post(api_url, params=params, headers=headers, json={"url": image_url})
        image_file = BytesIO(requests.get(image_url).content)
        image = Image.open(image_file)
    '''
    fig, ax = plt.subplots(figsize=(10,10))
    image = Image.open(image_path)
    ax.imshow(image, alpha=0.6)
    for face in faces:
        fr = face["faceRectangle"]
        fa = face["faceAttributes"]
        origin = (fr["left"], fr["top"])
        p = patches.Rectangle(origin, fr["width"],
                            fr["height"], fill=False, linewidth=2, color='b')
        ax.axes.add_patch(p)
        ax.text(origin[0], origin[1], "%s, %d"%(fa["gender"].capitalize(), fa["age"]),
                fontsize=16, weight="bold", va="bottom")

        if show_face_id:
            ax.text(origin[0], origin[1]+fr["height"], "%s"%(face["faceId"][:5]),
            fontsize=12, va="bottom")
    ax.axis("off")
    plt.show()
    # Explicitly closing image so it does not show in the notebook
    plt.close()
    return fig, faces

	
print("START of Program")
image_1 = input("Enter Image 1 Path or url ")
if len(image_1)<1 :
    print("Image Path not Entered using Sample Image")
    image_1 = "Photograph/Sample3-1.jpg"
image_2 = input("Enter Image 2 Path or url ")
if len(image_2)<1 :
    print("Image Path not Entered using Sample Image")
    image_2 = "Photograph/Sample3-2.jpg"

subscription_key, face_api_url, face_api_url_verify  = cnfg.config()

faces_1 = ImageProcessingAnnotateCombo(image_1, subscription_key, face_api_url)
faces_2 = ImageProcessingAnnotateCombo(image_2, subscription_key, face_api_url)
print(faces_1, faces_2)
'''
if len(faces_1)>1 or len(faces_2)>1 :
    print("Image has multiple faces. Can't compare image with multiple faces.")
    exit(0)
'''
faceID_1 = faces_1[1][0]['faceId']
faceID_2 = faces_2[1][0]['faceId']

result = face_compare(faceID_1, faceID_2, face_api_url_verify)
print("IDENTICAL: " , result['isIdentical'])
print("CONFIDENCE: " , result['confidence'])
print("END")