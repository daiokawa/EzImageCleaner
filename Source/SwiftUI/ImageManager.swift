import Foundation
import AppKit
import UniformTypeIdentifiers

struct ImageFile: Identifiable {
    let id = UUID()
    let url: URL
    let size: Int64
    let modifiedDate: String
    var dimensions: String?
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

@MainActor
class ImageManager: ObservableObject {
    @Published var images: [ImageFile] = []
    @Published var deletedCount = 0
    @Published var keptCount = 0
    @Published var totalFreedSpace: Int64 = 0
    
    private var deletedFiles: [(url: URL, originalIndex: Int)] = []
    private let fileManager = FileManager.default
    
    var formattedFreedSpace: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalFreedSpace)
    }
    
    func scanFolders(_ folders: [String], minSize: Int) async {
        images.removeAll()
        
        let supportedExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp", "heic", "avif"]
        
        await withTaskGroup(of: [ImageFile].self) { group in
            for folder in folders {
                group.addTask {
                    await self.scanFolder(folder, extensions: supportedExtensions, minSize: minSize)
                }
            }
            
            for await foundImages in group {
                self.images.append(contentsOf: foundImages)
            }
        }
        
        // Sort by size descending
        images.sort { $0.size > $1.size }
    }
    
    private func scanFolder(_ folderPath: String, extensions: [String], minSize: Int) async -> [ImageFile] {
        var foundImages: [ImageFile] = []
        
        guard let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: folderPath),
                                                     includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
                                                     options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
            return foundImages
        }
        
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]),
                  let fileSize = resourceValues.fileSize,
                  fileSize >= minSize else { continue }
            
            let fileExtension = fileURL.pathExtension.lowercased()
            guard extensions.contains(fileExtension) else { continue }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let modifiedDate = resourceValues.contentModificationDate.map { dateFormatter.string(from: $0) } ?? "Unknown"
            
            var imageFile = ImageFile(url: fileURL, size: Int64(fileSize), modifiedDate: modifiedDate)
            
            // Try to get image dimensions
            if let image = NSImage(contentsOf: fileURL),
               let rep = image.representations.first {
                imageFile.dimensions = "\(rep.pixelsWide) × \(rep.pixelsHigh)"
            }
            
            foundImages.append(imageFile)
        }
        
        return foundImages
    }
    
    func deleteImage(at index: Int) {
        guard index < images.count else { return }
        
        let image = images[index]
        
        // Move to trash
        do {
            try fileManager.trashItem(at: image.url, resultingItemURL: nil)
            deletedFiles.append((url: image.url, originalIndex: index))
            totalFreedSpace += image.size
            deletedCount += 1
            images.remove(at: index)
        } catch {
            print("Error deleting file: \(error)")
        }
    }
    
    func keepImage(at index: Int) {
        guard index < images.count else { return }
        keptCount += 1
    }
    
    func undoLastDeletion() {
        guard let lastDeleted = deletedFiles.popLast() else { return }
        
        // Note: Actual restoration from trash would require more complex implementation
        // For now, we'll just update the counts
        deletedCount -= 1
        
        // In a real implementation, you would restore the file from trash
        // and re-insert it into the images array at the appropriate position
    }
}