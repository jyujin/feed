/**\file
 *
 * \copyright
 * Copyright (c) 2013-2014, FEED Project Members
 * \copyright
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * \copyright
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * \copyright
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * \see Project Documentation: http://ef.gy/documentation/feed
 * \see Project Source Code: http://git.becquerel.org/jyujin/feed.git
 */

#define DEFAULT_OPTIONS "BWARDNXHI"

#include <feed/client.h>

int main (int argc, char**argv)
{
    try
    {
        return feed::processClient(argc, argv);
    }
    catch (feed::sqlite::exception &e)
    {
        std::cerr << "TOP LEVEL SQL EXCEPTION: " << e.what() << "\n";
    }
    catch (feed::exception &e)
    {
        std::cerr << "TOP LEVEL EXCEPTION: " << e.string << "\n";
    }

    return -5;
}
