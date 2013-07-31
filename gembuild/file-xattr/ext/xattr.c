/* 
    Ruby interface to filesystem extended attributes.
    This was based on an earlier work by aredridel@nbtsc.org
    I liked the way it extended the File class rather than introducing a new
    XAttr object.

    Substantially reworked to be platform portable (at least Mac OS X and RedHat)

    TODO: Allow FOLLOW/NONFOLLOW, CREATE/REPLACE, BULK SET

    Nick Townsend, April/May 2010 
    $Id$
*/

#include <ruby.h>
#include <ruby/io.h>

#ifdef DARWIN
#include <sys/xattr.h>
#define LSETXATTR(a,b,c,d,e)	setxattr(a,b,c,d,0,e|XATTR_NOFOLLOW)
#define SETXATTR(a,b,c,d,e)	setxattr(a,b,c,d,0,e)
#define FSETXATTR(a,b,c,d,e)	fsetxattr(a,b,c,d,0,e)
#define LGETXATTR(a,b,c,d)	getxattr(a,b,c,d,0,XATTR_NOFOLLOW)
#define GETXATTR(a,b,c,d)	getxattr(a,b,c,d,0,0)
#define FGETXATTR(a,b,c,d)	fgetxattr(a,b,c,d,0,0)
#define LISTXATTR(a,b,c)	listxattr(a,b,c,0)
#define LLISTXATTR(a,b,c)	listxattr(a,b,c,XATTR_NOFOLLOW)
#define FLISTXATTR(a,b,c)	flistxattr(a,b,c,0)
#define LREMOVEXATTR(a,b)	removexattr(a,b,XATTR_NOFOLLOW)
#define REMOVEXATTR(a,b)	removexattr(a,b,0)
#define FREMOVEXATTR(a,b)	fremovexattr(a,b,0)
#else
#include <attr/xattr.h>
#define LSETXATTR(a,b,c,d,e)	lsetxattr(a,b,c,d,e)
#define SETXATTR(a,b,c,d,e)	setxattr(a,b,c,d,e)
#define FSETXATTR(a,b,c,d,e)	fsetxattr(a,b,c,d,e)
#define LGETXATTR(a,b,c,d)	lgetxattr(a,b,c,d)
#define GETXATTR(a,b,c,d)	getxattr(a,b,c,d)
#define FGETXATTR(a,b,c,d)	fgetxattr(a,b,c,d)
#define LLISTXATTR(a,b,c)	llistxattr(a,b,c)
#define LISTXATTR(a,b,c)	listxattr(a,b,c)
#define FLISTXATTR(a,b,c)	flistxattr(a,b,c)
#define LREMOVEXATTR(a,b,c)	lremovexattr(a,b)
#define REMOVEXATTR(a,b)	removexattr(a,b)
#define FREMOVEXATTR(a,b)	fremovexattr(a,b)
#endif

#define MAXATTRSIZE 16000
#define XATTR_REPLACEORCREATE 0

/*
 *  call-seq:
 *      File.list_attrs(filename) -> array
 *
 *  Returns an array with all attributes
 *
 *      File.list_attrs(".") => ("type", "rating", "artist")
 *
 */

static VALUE rb_file_list_attrs(VALUE obj, VALUE fname)
{
    char *lval;
    int lsize, ix, len;
    VALUE retval;

    Check_Type(fname, T_STRING);

    lval = malloc(MAXATTRSIZE);

    lsize = LLISTXATTR(StringValueCStr(fname), lval, MAXATTRSIZE);

    if(lsize >= 0) {
	retval = rb_ary_new();
	for(ix = 0; ix < lsize; ix += len+1) {
	    len = strlen(lval+ix);
	    rb_ary_push(retval, rb_str_new(lval+ix, len));
	}
	free(lval);
	return retval;
    } else {
	free(lval);
	rb_sys_fail(StringValueCStr(fname));
    }
}

/*
 *  call-seq:
 *      file.list_attrs() -> array
 *
 *  Returns an array with all attributes
 *
 *      File.new(__FILE__).list_attrs() => ("type", "rating", "artist")
 *
 */

VALUE rb_file_list_attrsf(VALUE fobj)
{
    char *lval;
    int lsize, ix, len;
    VALUE retval;
    OpenFile *fptr;
    FILE *f;

    GetOpenFile(fobj, fptr);
    f = GetReadFile(fptr);

    Check_Type(fobj, T_FILE);

    lval = malloc(MAXATTRSIZE);

    lsize = FLISTXATTR(fileno(f), lval, MAXATTRSIZE);

    if(lsize >= 0) {
	retval = rb_ary_new();
	for(ix = 0; ix < lsize;ix += len+1) { 
	    len = strlen(lval+ix);
	    rb_ary_push(retval, rb_str_new(lval+ix, len));
	}
	free(lval);
	return retval;
    } else {
	free(lval);
	rb_sys_fail("");
    }
}

/*
 *  call-seq:
 *      File.get_all_attrs(filename) -> hash
 *
 *  Returns a hash with all attributes and their values
 *
 *      File.get_all_attrs(".") => ("mime" => "text/plain", "rating" => "4")
 *
 */

static VALUE rb_file_get_all_attrs(VALUE obj, VALUE fname)
{
    char *lval, *gval;
    int lsize, gsize, ix, len;
    VALUE retval;

    Check_Type(fname, T_STRING);

    lval   = malloc(MAXATTRSIZE);
    gval   = malloc(MAXATTRSIZE);

    lsize = LLISTXATTR(StringValueCStr(fname), lval, MAXATTRSIZE);

    if(lsize >= 0) {
	retval = rb_hash_new();
	for(ix = 0; ix < lsize; ix += len+1) { 
	    len = strlen(lval+ix);
	    gsize = GETXATTR(StringValueCStr(fname), lval+ix, gval, MAXATTRSIZE);
	    if(gsize >= 0) {
		rb_hash_aset(retval,
			rb_str_new(lval+ix, len),
			rb_str_new(gval, gsize));
	    } else {
		if(errno != ENODATA && errno != ENOATTR && errno != EPERM) {
		    free(lval);
		    free(gval);
		    rb_sys_fail(StringValueCStr(fname));
		}
	    }
	}
	free(lval);
	free(gval);
	return retval;
    } else {
	free(lval);
	free(gval);
	rb_sys_fail(StringValueCStr(fname));
    }
}

/*
 *  call-seq:
 *  	file.get_all_attrs() -> hash
 *
 *  Returns a hash with all attributes and their values
 *
 *  	File.new(__FILE__).get_all_attrs() => ("type" => "jpeg", "rat" => "4")
 *
 */

VALUE rb_file_get_all_attrsf(VALUE fobj)
{
    char *lval, *gval;
    int gsize, lsize, ix, len;
    VALUE retval;
    OpenFile *fptr;
    FILE *f;

    GetOpenFile(fobj, fptr);
    f = GetReadFile(fptr);

    Check_Type(fobj, T_FILE);

    lval = malloc(MAXATTRSIZE);
    gval = malloc(MAXATTRSIZE);

    lsize = FLISTXATTR(fileno(f), lval, MAXATTRSIZE); 
    if(lsize >= 0) {
	retval = rb_hash_new();
	for(ix = 0; ix < lsize; ix += len+1) {
	    len = strlen(lval+ix);
	    gsize = FGETXATTR(fileno(f), lval+ix, gval, MAXATTRSIZE);
	    if(gsize >= 0) {
		rb_hash_aset(retval,
			rb_str_new(lval+ix, len),
			rb_str_new(gval, gsize));
	    } else {
		if(errno != ENODATA && errno != ENOATTR && errno != EPERM) {
		    free(lval);
		    free(gval);
		    rb_sys_fail("");
		}
	    }
	}

	free(lval);
	free(gval);
	return retval;
    } else {
	free(lval);
	free(gval);
	rb_sys_fail("");
    }
}
  

/*
 *  call-seq:
 *      File.get_attr(filename, attribute) -> attribute_value
 *
 *  Returns the value of the attribute <i>attribute</i>
 *
 *      File.get_attr(".", "description") => "ruby-xattr directory and files"
 *
 */

static VALUE rb_file_get_attr(VALUE obj, VALUE fname, VALUE aname)
{
    char *aval;
    int size;
    VALUE retval;

    Check_Type(fname, T_STRING);
    Check_Type(aname, T_STRING);

    aval = malloc(MAXATTRSIZE);

    size = GETXATTR(StringValueCStr(fname), StringValueCStr(aname), aval, MAXATTRSIZE);

    if(size >= 0) {
	retval = rb_str_new(aval, size);
	free(aval);
	return retval;
    } else {
	free(aval);
	if(errno != ENOATTR && errno != ENODATA) {
	    rb_sys_fail(StringValueCStr(fname));
	}
	return Qnil;
    }
}

/*
 *  call-seq:
 *  	file.get_attr(attribute) -> attribute_value
 *
 *  Returns the value of <i>attribute</i> for the file
 *
 *  	File.new(__FILE__).get_attr("description") # => "test script"
 *
 */

VALUE rb_file_get_attrf(VALUE fobj, VALUE aname)
{
    char *aval;
    int size;
    VALUE retval;
    OpenFile *fptr;
    FILE *f;

    GetOpenFile(fobj, fptr);
    f = GetReadFile(fptr);

    Check_Type(fobj, T_FILE);
    Check_Type(aname, T_STRING);

    aval = malloc(MAXATTRSIZE);

    size = FGETXATTR(fileno(f), StringValueCStr(aname), aval, MAXATTRSIZE);
    if(size >= 0) {
	retval = rb_str_new(aval, size);
	free(aval);
	return retval;
    } else {
	free(aval);
	if(size != ENODATA && size != ENOATTR) {
	    rb_sys_fail("");
	}
	return Qnil;
    }
}

/*
 *  call-seq:
 *  	File.set_attr(filename, attribute, attribute_value) -> attribute_value
 *
 *  Sets the attribute <i>attribute</i> for the file <i>filename</i>
 *
 *  	File.set_attr("test.rb", "description", "test script") # => "test script"
 *
 */


static VALUE rb_file_set_attr(VALUE obj, VALUE fname, VALUE aname, VALUE aval)
{
    int ret;

    Check_Type(fname, T_STRING);
    Check_Type(aname, T_STRING);
    Check_Type(aval, T_STRING);

    ret = SETXATTR(StringValueCStr(fname), StringValueCStr(aname), StringValueCStr(aval), RSTRING(aval)->len, XATTR_REPLACEORCREATE);

    if(ret == 0) {
	return aval;
    } else {
	rb_sys_fail(StringValueCStr(fname));
    }
}

/*
 *  call-seq:
 *  	file.set_attr(attribute, attribute_value) -> attribute_value
 *
 *  Sets the attribute <i>attribute</i> for the file.
 *
 *  	File.new("test.rb").set_attr("description", "test script") # => "test script"
 *
 */

VALUE rb_file_set_attrf(VALUE fobj, VALUE aname, VALUE aval)
{
    int ret;
    OpenFile *fptr;
    FILE *f;

    GetOpenFile(fobj, fptr);
    f = GetReadFile(fptr);

    Check_Type(fobj, T_FILE);
    Check_Type(aname, T_STRING);
    Check_Type(aval, T_STRING);
    ret = FSETXATTR(fileno(f), StringValueCStr(aname), StringValueCStr(aval), RSTRING(aval)->len, XATTR_REPLACEORCREATE);
    if(ret == 0) {
	return aval;
    } else {
	rb_sys_fail("");
    }
}

/*
 *  call-seq:
 *      File.remove_attr(filename, attribute)
 *
 *  Removes <i>attribute</i> from the given file
 *
 *      File.remove_attr(".", "description") 
 *
 */

static VALUE rb_file_remove_attr(VALUE obj, VALUE fname, VALUE aname)
{
    int ret;

    Check_Type(fname, T_STRING);
    Check_Type(aname, T_STRING);

    ret = REMOVEXATTR(StringValueCStr(fname), StringValueCStr(aname));
    if (ret != 0)
	rb_sys_fail(StringValueCStr(fname));
    return 1;
}

/*
 *  call-seq:
 *  	file.remove_attr(attribute)
 *
 *  Removes <i>attribute</i> from the file
 *
 *  	File.new(__FILE__).remove_attr("description")
 *
 */

VALUE rb_file_remove_attrf(VALUE fobj, VALUE aname)
{
    int ret;
    OpenFile *fptr;
    FILE *f;

    GetOpenFile(fobj, fptr);
    f = GetReadFile(fptr);

    Check_Type(fobj, T_FILE);
    Check_Type(aname, T_STRING);

    ret = FREMOVEXATTR(fileno(f), StringValueCStr(aname));
    if (ret != 0)
	rb_sys_fail("");
    return 1;
}

void Init_xattr () {
    rb_define_singleton_method(rb_cFile, "list_attrs", rb_file_list_attrs, 1);
    rb_define_singleton_method(rb_cFile, "get_all_attrs", rb_file_get_all_attrs, 1);
    rb_define_singleton_method(rb_cFile, "get_attr", rb_file_get_attr, 2);
    rb_define_singleton_method(rb_cFile, "set_attr", rb_file_set_attr, 3);
    rb_define_singleton_method(rb_cFile, "remove_attr", rb_file_remove_attr, 2);
    rb_define_method(rb_cFile, "list_attrs", rb_file_list_attrsf, 0);
    rb_define_method(rb_cFile, "get_all_attrs", rb_file_get_all_attrsf, 0);
    rb_define_method(rb_cFile, "get_attr", rb_file_get_attrf, 1);
    rb_define_method(rb_cFile, "set_attr", rb_file_set_attrf, 2);
    rb_define_method(rb_cFile, "remove_attr", rb_file_remove_attrf, 1);
}
/* vim: set ts=8 sw=4 sts=4: */
