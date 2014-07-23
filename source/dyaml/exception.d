
//          Copyright Ferdinand Majerech 2011.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

///Exceptions thrown by D:YAML and _exception related code.
module dyaml.exception;


import std.algorithm;
import std.array;
import std.string;
import std.conv;

alias to!string str;


/// Base class for all exceptions thrown by D:YAML.
class YAMLException : Exception
{
    /// Construct a YAMLException with specified message and position where it was thrown.
    public this(string msg, string file = __FILE__, int line = __LINE__)
        @safe pure nothrow
    {
        super(msg, file, line);
    }
}

/// Position in a YAML stream, used for error messages.
struct Mark
{
    private:
        /// Line number.
        ushort line_;
        /// Column number.
        ushort column_;

    public:
        /// Construct a Mark with specified line and column in the file.
        this(const uint line, const uint column) @safe pure nothrow @nogc
        {
            line_   = cast(ushort)min(ushort.max, line);
            column_ = cast(ushort)min(ushort.max, column);
        }

        /// Get a string representation of the mark.
        string toString() @safe pure nothrow const
        {
            /// Line/column numbers start at zero internally, make them start at 1.
            static string clamped(ushort v) @safe pure nothrow
            {
                return str(v + 1) ~ (v == ushort.max ? " or higher" : "");
            }
            return "line " ~ clamped(line_) ~ ",column " ~ clamped(column_);
        }
}

static assert(Mark.sizeof == 4, "Unexpected Mark size");

package:
// A struct storing parameters to the MarkedYAMLException constructor.
struct MarkedYAMLExceptionData
{
    // Context of the error.
    string context;
    // Position of the context in a YAML buffer.
    Mark contextMark;
    // The error itself.
    string problem;
    // Position if the error.
    Mark problemMark;
}

// Base class of YAML exceptions with marked positions of the problem.
abstract class MarkedYAMLException : YAMLException
{
    // Construct a MarkedYAMLException with specified context and problem.
    this(string context, Mark contextMark, string problem, Mark problemMark,
         string file = __FILE__, int line = __LINE__) @safe pure nothrow
    {
        const msg = context ~ '\n' ~
                    (contextMark != problemMark ? contextMark.toString() ~ '\n' : "") ~
                    problem ~ '\n' ~ problemMark.toString() ~ '\n';
        super(msg, file, line);
    }

    // Construct a MarkedYAMLException with specified problem.
    this(string problem, Mark problemMark, string file = __FILE__, int line = __LINE__)
        @safe pure nothrow
    {
        super(problem ~ '\n' ~ problemMark.toString(), file, line);
    }

    /// Construct a MarkedYAMLException from a struct storing constructor parameters.
    this(ref const(MarkedYAMLExceptionData) data) @safe pure nothrow
    {
        with(data) this(context, contextMark, problem, problemMark);
    }
}

// Constructors of YAML exceptions are mostly the same, so we use a mixin.
//
// See_Also: YAMLException
template ExceptionCtors()
{
    public this(string msg, string file = __FILE__, int line = __LINE__)
        @safe pure nothrow
    {
        super(msg, file, line);
    }
}

// Constructors of marked YAML exceptions are mostly the same, so we use a mixin.
//
// See_Also: MarkedYAMLException
template MarkedExceptionCtors()
{
    public:
        this(string context, Mark contextMark, string problem, Mark problemMark,
             string file = __FILE__, int line = __LINE__) @safe pure
        {
            super(context, contextMark, problem, problemMark,
                  file, line);
        }

        this(string problem, Mark problemMark, string file = __FILE__, int line = __LINE__)
            @safe pure
        {
            super(problem, problemMark, file, line);
        }

        this(ref const(MarkedYAMLExceptionData) data) @safe pure nothrow
        {
            super(data);
        }
}
