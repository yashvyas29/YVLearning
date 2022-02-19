// To use app classes in playground
import YVLearning
// To use Task in playground
//import _Concurrency
// To hide the unnecessary duplicate framework logs
//import PlaygroundSupport
//defer{ PlaygroundPage.current.finishExecution() }

let structuredConcurrency = StructuredConcurrency()
/*
Task {
    let imagesSerial = try? await structuredConcurrency.fetchImages()
    debugPrint("fetchImages: \(imagesSerial?.count ?? 0)")
    // Playground doesn't support async let till
//    async let imagesParallel = try? structuredConcurrency.fetchImages()
//    debugPrint("fetchImages async let: \(await imagesParallel?.count ?? 0)")
}
 */
