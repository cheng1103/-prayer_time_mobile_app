Future<T> retry<T>(Future<T> Function() action,
    {int maxRetries = 3, Duration delay = const Duration(seconds: 2)}) async {
  int retryCount = 0;
  while (retryCount < maxRetries) {
    try {
      return await action();
    } catch (e) {
      retryCount++;
      if (retryCount == maxRetries) {
        rethrow; // Re-throw the error after max retries
      }
      await Future.delayed(delay); // Wait before retrying
    }
  }
  throw Exception('Failed after $maxRetries retries');
}
