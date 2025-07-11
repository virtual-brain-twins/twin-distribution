class SpackException(Exception):

    def __init__(self, message):
        super().__init__(message)
        self.message = str(message)

    def __str__(self):
        return self.message


class BashrcException(SpackException):
    """
    To be thrown when an operation on .bashrc file fails.
    """
