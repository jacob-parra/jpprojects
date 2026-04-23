---
title: Audiobookshelf
layout: default
---


<img src="/jpprojects/images/images/zima.png" class="float_img" alt="Zima">
<img src="/jpprojects/images/images/audiobookshelf.png" class="float_img" alt="Audiobookshelf">

## Audiobookshelf

Audiobookshelf is a self hosted library option. I picked it for it's simplicity and support for both audio books and ebooks. It supports lots of media file types, is really easy to set up and use, and looks clean enough

#### 1. Install the app

In the Zima dashboard, click the App Store and search for Audiobookshelf. Click on the first listed app, and click the dropdown arrow on the Install button. Click Custom Install.

You need to change two of the path mappings:

- Set `/media/<pool name>/Audiobooks` on ZimaOS to `/audiobooks` on Audiobookshelf
- Set `/media/<pool name>/Podcasts` on ZimaOS to `/podcasts` on Audiobookshelf
- I also recommend using the + Add button in the Volumes section to add normal Book mapping: `/media/<pool name>/Books` on ZimaOS to `/books` on Audiobookshelf

This will automatically create these folders on your pool, which you can fill with your content after

Leave the other configs the same. Then click the blue Install button at the bottom.

#### 2. Access the Web App

Audiobookshelf will be accessed at the IP of the Zima host at port 13378.

First, you need to create the root user. Then, login with the root user.

#### 3. Create a Library

Click the top right Add Library. All you need is give a Library Name, choose an Icon, create a Folder Path (like `/books/<library title>` or `/audiobooks/<library title>`. If these folder paths don't exist, they will be created) and click Create.

Then, in Zima Files, navigate to the newly created folder to add your books.

For every book you add, create a subfolder named the same as the title of the book. Then, within that subfolder, add your book files. Audiobookshelf supports several audio formats (M4B, MP3, AAC, FLAC, OGG, and WAV) and ebook formats (EPUB, PDF, CBR, CBZ, MOBI, and AZW3).