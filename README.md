# Wordpress REST API Client
Simple Wordpress REST API Client for Android, iOS, macOS, Windows, and Linux built in Embarcadero Delphi.

Impliments viewing posts and posting posts with an image. Mainly built and tested for desktop usage on Windows but also lightly tested on macOS and Android.

Find more information about the Wordpress REST API:

<https://developer.wordpress.org/rest-api/>

The Endpoint field is require for reading and writing. An ending forward slash ( / ) is required as the last character.

Sample Endpoint with mod_rewrite support:
yourdomain/wp-json/wp/v2/

Sample Endpoint without mod_rewrite support:
yourdomain/?rest_route=/wp/v2/

This application supports HTTP Basic Authentication. The Wordpress installation needs to support this (which is usually done via a third party plugin). You can find such a plugin here: 

<https://github.com/WP-API/Basic-Auth>

The Username and Password fields may be required for reading from the endpoint if the permissions of the endpoint are set up that way.

The Username and Password fields are required for writing to the endpoint.

Find out more about Embarcadero Delphi:

<https://www.embarcadero.com/products/delphi>
