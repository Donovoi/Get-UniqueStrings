

using System;
using System.IO.MemoryMappedFiles;
using System.Runtime.InteropServices;

namespace Application
{
    class Program
    {
        static void Main(string[] args)
        {

            var fileName = args[0];
            long offset = 0x10000000; // 256 megabytes
            long length = 0x20000000; // 512 megabytes
            using (var mmf = MemoryMappedFile.CreateFromFile(fileName, FileMode.Open, "filename"))
            {
                // Create a random access view, from the 256th megabyte (the offset)
                // to the 768th megabyte (the offset plus length).
                using (var accessor = mmf.CreateViewAccessor(offset, length))
                {
                    int bufferSize = 1024;


                    // Make changes to the view.
                    for (long i = 0; i < length; i += bufferSize)
                    {
                      accessor.Read(i, out int buffer);
                        global::System.Console.WriteLine(buffer.ToString());
                    }
                }
            }
        }
    }
}

