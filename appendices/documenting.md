# Documenting MagAO-X

## Where the documentation lives

This source code for this documentation lives in the [magao-x/handbook](https://github.com/magao-x/handbook) repository. Parts of the documentation pertaining to the core C++ code are generated from the code in [magao-x/MagAOX](https://github.com/magao-x/MagAOX), which is documented in Doxygen. (TODO: explain how to make cross-references.)

The built copy of this documentation is hosted at [https://magao-x.github.io/handbook/](https://magao-x.github.io/handbook/) via [GitHub Pages free hosting](https://pages.github.com/). When changes are pushed to the `master` branch of [magao-x/handbook](https://github.com/magao-x/handbook), a CircleCI job builds and updates the `gh-pages` branch of the repository, with changes reflected on the GitHub Pages site 1-15 minutes later.

## How to make changes

### Installing the required software

You will need Python 3.5 or newer (with `pip`) and a recent version of `git`.

  1. Clone https://github.com/magao-x/handbook to your own computer
     ```bash
     # full clone
     $ git clone https://github.com/magao-x/handbook.git

     # shallow clone (faster)
     $ git clone --depth=1 https://github.com/magao-x/handbook.git
     ```
  2. Change into the directory where you just cloned the documentation and install software so you can preview your changes.
     ```bash
     # if 'pip' and 'python' are provided by Python 3.x:
     $ pip install --user -r requirements.txt

     # if your OS calls pip for Python 3.x 'pip3':
     $ pip3 install --user -r requirements.txt
     ```
     (Installing Python 3 is outside the scope of this document, but [Anaconda](https://www.anaconda.com/distribution/) is a popular installer.)
  3. Ensure `sphinx-build` is on the path
     ```bash
     $ which sphinx-build
     /Users/jlong/miniconda3/bin/sphinx-build
     ```
     (If you're using your OS-provided Python, and don't see output for `which sphinx-build`, you should make sure `$HOME/.local/bin` is on `$PATH`.)

You now have a copy of the sources for the handbook. If you're just editing an existing document, [skip ahead](#edit-and-publish).

### Creating a brand new document

  1. Create a `.md` (or `.rst`, see [below](#markup)) file with the name you want
  2. Find the file with the appropriate `.. toctree::` directive (probably `index.rst`) and edit it to add the base name of your file (e.g. `funny-business.md` would be `funny-business` in the toctree)

### Edit and publish

Finally, to preview and publish your edits:

  1. Edit the document you want to change
  2. Run `make html` (in the directory you cloned into)
  3. Open `_build/html/index.html` to see the updated site, and verify your changes look good
  4. `git add ./path/to/file/you/changed.md` and `git commit -m "Description of your changes"`
  5. `git push origin master`

If everything looks good, the public copy of the docs will update automatically!

### Markup

Documents can be written in Markdown ([CommonMark](https://spec.commonmark.org/0.29/) variant), in which case the filename must end with `.md`, or reStructuredText, in which case the filename must end with `.rst`. If you want to see how a particular bit of formatting was achieved, you can click the "Page source" link at the bottom of the page.

The following examples are written in Markdown, since that is the language most new contributors are likely to be familiar with. Accomplishing trickier formatting may require dipping one's toes into [reStructuredText](http://www.sphinx-doc.org/en/stable/usage/restructuredtext/basics.html) or [mixing both languages](https://recommonmark.readthedocs.io/en/latest/auto_structify.html#embed-restructuredtext).

### Linking

To link to a section within the same document: `[my link text](#my-section-title)` makes a link to a section headed "My Section Title" with "my link text" as the clickable text. All spaces are converted to dashes, and capitalized letters are converted to lowercase.

### Code samples

#### Inline code

To include some code inline, enclose it in backticks (left of the `1` key on most US keyboards).

**Example markup:**

```
Before starting, execute `sudo do-things` in your terminal
```

**Output:**

Before starting, execute `sudo do-things` in your terminal

#### Blocks of code

Blocks of code are "fenced" by three backticks on their own line before and after the code block. (If you need to include such a sequence in your block of code, you can use three tildes instead.)

**Example markup:**

~~~
```
for i in range(8):
    print("Step", i)
```
~~~

**Output:**

```
for i in range(8):
    print("Step", i)
```

#### Syntax highlighting

By default, the documentation system applies syntax highlighting for Python code to code blocks. If your code is in another language, you include its name on the line after the first set of backticks.

**Example markup:**

~~~
```bash
#!/bin/bash
set -exuo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"
```
~~~

**Output:**

```bash
#!/bin/bash
set -exuo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"
```

### Math

Equations can be inserted as a special variety of code block.

**Example markup:**

~~~
```math
\mu = m - M = 5 \log_{10}\left(\frac{d}{10\,\mathrm{pc}}\right)
```
~~~

**Output:**

```math
\mu = m - M = 5 \log_{10}\left(\frac{d}{10\,\mathrm{pc}}\right)
```

### External files

If you want to include a downloadable file (e.g. filter transmission curve table, PDF document, etc.) you will have to dip your toes into the ["embedded reST"](https://recommonmark.readthedocs.io/en/latest/auto_structify.html#embed-restructuredtext) feature of reCommonMark.

**Example markup:**

~~~
```eval_rst
:download:`Click here to download the star logo <mini-star.png>`
```
~~~

**Output:**

```eval_rst
:download:`Click here to download the star logo <mini-star.png>`
```

Alternatively, you can simply write the whole document in reStructuredText as in the [Preliminary design review](pdr/index) page.

### Images

By default, images are included inline and left aligned. Image inclusion takes the form `![](path)` where `path` is the path relative to the current file you're editing.

Example markup:

```
![](mini-star.png)
```

Output:

![](mini-star.png)

*Note: reCommonMark does not correctly handle "alternative text", normally placed between the square brackets, meaning the `alt=` attribute is not populated and the handbook is not as accessible to the visually impaired as it could be.*

## Implementation details

This documentation is assembled with a Python-based tool called [Sphinx](http://www.sphinx-doc.org/en/stable/). Sphinx uses the [files](#where-the-documentation-lives) to make the docs.
