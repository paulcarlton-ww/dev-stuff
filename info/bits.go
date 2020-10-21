package info

import (
	"fmt"
	"reflect"
	"strings"
)

// examiner returns a string containing details of an interface including type and contents, useful for debugging and understanding data
func examiner(t reflect.Type, depth int, data interface{}) string {
	details := fmt.Sprintf("%sType: %-10s kind: %-8s Package: %s\n", strings.Repeat("\t", depth), t.Name(), t.Kind(), t.PkgPath())
	switch t.Kind() {
	case reflect.Array, reflect.Chan, reflect.Map, reflect.Ptr, reflect.Slice:
		details = details + fmt.Sprintf("%sContained type...\n",strings.Repeat("\t", depth+1))
		details = details + examiner(t.Elem(), depth+1, data)
	case reflect.Struct:
		for i := 0; i < t.NumField(); i++ {
			f := t.Field(i)
			details = details + fmt.Sprintf("%sField: %d: name: %-10s type: %-8s kind: %-12s anon: %-6t package: %s\n",
				strings.Repeat("\t", depth+1), i+1, f.Name, f.Type.Name(), f.Type.Kind().String(), f.Anonymous, f.PkgPath)
			if f.Tag != "" {
				details = details + fmt.Sprintf("%sTags: %s\n", strings.Repeat("\t", depth+2), f.Tag)
			}
			if f.Type.Kind() == reflect.Struct {
				details = details + examiner(f.Type, depth+2, data)
			}
		}
	}
	return details
}

// displayM displays the contents of a model.M
func displayM(m *model.M) string {
	text := fmt.Sprintf("fields data...\n")
	for k, v := range (*m) {
		text += fmt.Sprintf("field: %s, type: %s, data: %s\n", k, reflect.TypeOf(v), util.GetFieldText(v))
	}
	return text
}
