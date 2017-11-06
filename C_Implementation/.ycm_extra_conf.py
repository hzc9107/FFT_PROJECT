def FlagsForFile(filename, **kwargs):
    return {
        'flags' : [ '-x', 'c++', '-std=c++11', '-pipe', '-O2', '-lm', '-g'],
    }
