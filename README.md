# CFSelenium
A Selenium framework for Coldfusion utilising the native Java-bindings

This framework aims to do the pretty much the same as teamcfadvance's CFSelenium: provide a native client library for the Selenium WebDriver that allows you to write tests, using CFML, which will drive a browser and allow you to interact with the page and elements.

I don't claim this is better; in fact it's approach is quite different - as this is full framework that abstracts and exposes Selenium in very specific ways to suit our company's needs.

**LICENSE**

MIT License

Copyright (c) 2018 Thomas Grud Frengler

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

**ORIGINS:**

The project originally came about when my company decided to switch from our old test Javascript framework to using Selenium. 
teamcfadvance's CFSelenium was sadly not in a working state at that point and with no alternatives (and no time to waste), the only other option for me was to create my own framework from scratch, based on the native Java-bindings for Selenium.

**USAGE:**

I was encouraged to share this framework here on GitHub by my colleagues. As it stands the framework is provided "as is" and will not be extended according to feedback. It's public  mostly for educational/curiosty reasons, so that anyone else who might want to see how Coldfusion and Selenium working together could be achieved and realized as a fully fledged framework. It's built completely towards my company's way - and mine, as the chief architect - of working and is not meant to be easy for others to implement and use. That was the original intention when I put it on GitHub, but as time went on, it became clear that it was practically impossible to keep developing it for our use while not locking it down or restricting it for the public.

**REQUIREMENTS**

Lucee 5+
Supports the use of Mark Mandel's **Javaloader**, although with the move to Lucee-only it's likely to be removed.
