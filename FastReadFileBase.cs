using System.ComponentModel;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace Application
{
    public static class FastReadFileBase
    {

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Reliability", "CA2004:RemoveCallsToGCKeepAlive")]
        public static T[] FastRead<T>(FileStream fs, int count) where T : struct
        {
            int sizeOfT = Marshal.SizeOf(typeof(T));

            long bytesRemaining = fs.Length - fs.Position;
            long wantedBytes = count * sizeOfT;
            long bytesAvailable = Math.Min(bytesRemaining, wantedBytes);
            long availableValues = bytesAvailable / sizeOfT;
            long bytesToRead = (availableValues * sizeOfT);

            if ((bytesRemaining < wantedBytes) && ((bytesRemaining - bytesToRead) > 0))
                Console.WriteLine("Requested data exceeds available data and partial data remains in the file.");

            T[] result = new T[availableValues];

            GCHandle gcHandle = GCHandle.Alloc(result, GCHandleType.Pinned);

            var ipp = new System.Threading.NativeOverlapped();  // need this with above pInvoke

            try
            {
                uint bytesRead;
                if (!ReadFile(
                    fs.SafeFileHandle,
                    gcHandle.AddrOfPinnedObject(),
                    (uint)bytesToRead,
                    out bytesRead, ref ipp))
                {
                    throw new IOException("Unable to read file.", new Win32Exception(Marshal.GetLastWin32Error()));
                }
                Debug.Assert(bytesRead == bytesToRead);
            }

            finally
            {
                gcHandle.Free();
            }

            GC.KeepAlive(fs);

            return result;
        }
        // https://stackoverflow.com/questions/66789631/fastest-way-to-read-large-binary-file-into-array-of-int-in-c-sharp/67332253#67332253

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool ReadFile(Microsoft.Win32.SafeHandles.SafeFileHandle hFile, [Out] IntPtr lpBuffer, uint nNumberOfBytesToRead,
                                out uint lpNumberOfBytesRead, [In] ref System.Threading.NativeOverlapped lpOverlapped);
    }
}