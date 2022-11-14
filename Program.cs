

using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO.MemoryMappedFiles;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;
using Application;
using Windows.Storage;

namespace Application
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var folderPath = args[0];
            // enumerate through the files in the folder recursively
            var files = Directory.EnumerateFiles(folderPath, "*.*", SearchOption.AllDirectories);
            foreach (var file in files)
            {
                byte[] b = FastReadFileBase.FastRead<byte>(new FileStream(file, FileMode.Open), int.MaxValue);
                string mixedString = Encoding.ASCII.GetString(b);
                // Use regex to filter out anynon ascii characters
                var sortedString = Regex.Replace(mixedString, @"[^\x20-\x7E]", string.Empty);
                // remove any new line or return characters and split on spaces
                var words = sortedString.Split(' ');
                foreach (var word in words)
                {
                    var questionSortedString = Regex.Replace(word, @"(\?{2,})", string.Empty);
                    // regex search for any email addresses according to rfc 5322, or ip address according to rfc 3986, or url according to rfc 3986
                    var email = Regex.Match(questionSortedString, @"^(([^<>()[\]\\.,;:\s@\""]+"
                        + @"(\.[^<>()[\]\\.,;:\s@\""]+)*)|(\"".+\""))@"
                        + @"((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|"
                        + @"(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$", RegexOptions.IgnoreCase);
                    var ip = Regex.Match(questionSortedString, @"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", RegexOptions.IgnoreCase);
                    var url = Regex.Match(questionSortedString, @"^((http|https|ftp)://)?(www.)?[a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)$", RegexOptions.IgnoreCase);
                    var outputfile = @"C:\Users\micha\Documents\output.txt";
                    var emailvalue = email.Success ? email.Value : "";
                    var ipvalue = ip.Success ? ip.Value : "";
                    var urlvalue = url.Success ? url.Value : "";
                    await WriteFileAsync(Outputfile, emailvalue);
                    await WriteFileAsync(outputfile, ipvalue);
                    await WriteFileAsync(outputfile, urlvalue);


                }
            }
        }

        static async Task WriteFileAsync(Windows.Storage.IStorageFile file, string[] content)
        {
            Console.WriteLine("Async Write File has started.");
            if (file != null)
            {
                await FileIO.AppendLinesAsync(file, content);
            }
            Console.WriteLine("Async Write File has completed.");
        }
    }
}


