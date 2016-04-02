import std.stdio;
import std.algorithm;
import std.typecons : Tuple;
import std.utf;

import std.experimental.allocator : makeArray;
import std.experimental.allocator.mallocator : Mallocator;
import std.experimental.allocator.building_blocks.allocator_list : AllocatorList;
import std.experimental.allocator.building_blocks.region : Region;
import std.experimental.allocator.building_blocks.null_allocator : NullAllocator;
import std.algorithm : max;
import std.exception : assumeUnique;

struct WordInfo
{
    string word;
    int count;

    int opCmp(const WordInfo other) @safe pure nothrow const
    {
        if (this.count < other.count) return 1;
        else if (this.count > other.count) return -1;
        else if (this.word > other.word) return 1;
        // this.word != other.word
        else return -1;
    }
}

void main()
{
    auto batchAllocator = AllocatorList!(
        (size_t n) => Region!Mallocator(max(n, 1024 * 1024)),
        NullAllocator,
    )();

    WordInfo[string] words;

    foreach (line; stdin.byLine(KeepTerminator.no))
    {
        foreach (word; line.splitter!(a => a == ' ' || a == '\t')) if (word.length > 0)
        {
            if (auto count = word in words)
            {
                (*count).count += 1;
            }
            else
            {
                auto id = batchAllocator.makeArray!char(word.byChar).assumeUnique();
                words[id] = WordInfo(id, 1);
            }
        }
    }

    foreach (word; words.values.sort())
    {
        writeln(word.word, '\t', word.count);
    }
}
