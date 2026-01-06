---
title: Github Pages
layout: default
---

## Github Pages

Github Pages is a simple way to host simple static websites, like this one, directly from a Github Repo. It supports markdown natively via Jekyll, a static site generator perfect for sites focused on content over interactability. It's fast, secure and simple, perfect for the free hosting Github Pages provides.

The following instructions detail my process of creating this very site.

<hr>

**1 Create the Github Repo**

Leave all the default settings, but provide a good name (like homelab) and description.

**2 Add the initial files**

This is the file structure:

```
homelab/
├── index.md
├── _config.yml
├── _layouts/
│   └── default.html
├── projects/
│   └── project.md
```

These are basic templates for index.md, _config.yml and default.html:

**_config.yml**

```
title: Homelab
description: Homelab projects and infrastructure documentation
markdown: kramdown
```

**_layouts/defualt.html**

This file will be applied to every page in the site to place a top navbar and provide metadata.

```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>{{ page.title }} | {{ site.title }}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="/homelab/assets/style.css">
</head>
<body>
  <div class="Default_Header">
    <h1 class="title">Homelab</h1>
    <nav>
      <a href="{{ site.baseurl }}/">Home</a>
      <a href="/insertsite">Personal Site</a>
    </nav>
  </div>

  <main>
    {{ content }}
  </main>

<footer class="site-footer">
  <div class="footer-content">
    <hr>
    <p>
      © <span id="year"></span> Name ·
      jpprojects ·
      <a href="link" target="_blank" rel="noopener">LinkText</a>
    </p>
    <p class="footer-subtext">
    Built with Markdown · Hosted on GitHub Pages

  </div>
</footer>

<script>
  document.getElementById("year").textContent = new Date().getFullYear();
</script>

</body>
</html>
```

**index.md**

Note the markdown syntax in this file, as well as the application of the layout template file. The index page acts as the hub for the rest of the link pages. Note also the lack of file extension in the markdown link.

```
---
title: Homelab
layout: default
---

# Homelab Projects

This site documents my homelab experiments, infrastructure, and lessons learned.

## Projects
- [Example Text](/homelab/projects/example)

```

**3 Enable Pages**

Navigate to the Settings tab in the top of the Repo menu, and click "Pages" in the left sidebar under "Code and automation". Make sure "Source" is set to "Deploy from a brach", and set the branch to "main" and the folder to "root". Click save and wait about a minute or so

**4 Add content and additional pages**

Follow the index.md template to add more pages of content in markdown syntax. Link to each page in the index.md file.

<hr>

The following steps are optional to further sophisticate a Pages site.

**5 Add Styling**

Create an "assets" folder in root, and add a "style.css" file in it. Add a link to the file in the `<head>` tag of the default.html template file so that all pages can share the same styling: `<link rel="stylesheet" href="/homelab/assets/style.css">`.

Jekyll "translates" markdown into normal html syntax, tags and all. CSS can then be applied to those html tags like normal. Div tags with ids and classes can also be added directly among markdown syntax to further refine styling.

**6 Add File Downloads**

The easiest way to support downloadable files is to keep them in a "downloads" folder in the root of the repository. Then link to them with this syntax: `[script](/homelab/downloads/script.txt)`. Upon clicking the link, the file will be opened in the browser or immediately download (depends on the browser). 

Alternatively, use this html syntax: `<a href="/homelab/downloads/script.txt" download>Download</a>`

**7. Build Locally**

Rather than commiting to see every change, build with Jekyll locally first:

- Download <a href="https://rubyinstaller.org/">RubyInstaller<a>
  - Choose Ruby 3.3.x (x64) WITH DevKit (Jekyll doens't support Ruby 4 at the time of writing)
  - When running the installer, select both “Add Ruby executables to PATH” and “Install MSYS2 and development toolchain”
  - Verify proper installation with `ruby -v` and `gem -v`. Output should be `Ruby 3.3.x`.
- Install Jekyll
  - `gem install jekyll bundler`
  - Verify proper installation with `jekyll -v`.
- Build
  - cd into the repo folder
  - Build with `jekyll serve`
- The site will be available at `localhost:4000/repo_name` (127.0.0.1)

Note: the site refreshes on project saves, simplifing editing and reducing the number of commits on the repo.