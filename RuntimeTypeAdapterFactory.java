import  com.google.gson.*;
import  com.google.gson.reflect.TypeToken;
import  com.google.gson.stream.*;
import  java.io.IOException;
import  java.util.*;

public final class RuntimeTypeAdapterFactory<T> implements TypeAdapterFactory {
  private final Class<?> baseType;
  private final String typeFieldName;
  private final Map<String, Class<?>> labelToSubtype = new LinkedHashMap<>();
  private final Map<Class<?>, String> subtypeToLabel = new LinkedHashMap<>();

  private RuntimeTypeAdapterFactory(Class<?> baseType, String typeFieldName) {
    if (baseType == null || typeFieldName == null) {
      throw new NullPointerException();
    }
    this.baseType = baseType;
    this.typeFieldName = typeFieldName;
  }

  public static <T> RuntimeTypeAdapterFactory<T> of(Class<T> baseType, String typeFieldName) {
    return new RuntimeTypeAdapterFactory<T>(baseType, typeFieldName);
  }

  public RuntimeTypeAdapterFactory<T> registerSubtype(Class<? extends T> subtype, String label) {
    if (subtype == null || label == null) {
      throw new NullPointerException();
    }
    if (labelToSubtype.containsKey(label) || subtypeToLabel.containsKey(subtype)) {
      throw new IllegalArgumentException("labels and types must be unique");
    }
    labelToSubtype.put(label, subtype);
    subtypeToLabel.put(subtype, label);
    return this;
  }

  @Override
  @SuppressWarnings("unchecked")
  public <R> TypeAdapter<R> create(Gson gson, TypeToken<R> type) {
    Class<?> rawType = type.getRawType();
    if (!baseType.isAssignableFrom(rawType)) {
      return null;
    }

    final Map<String, TypeAdapter<?>> labelToDelegate = new LinkedHashMap<>();
    final Map<Class<?>, TypeAdapter<?>> subtypeToDelegate = new LinkedHashMap<>();

    for (Map.Entry<String, Class<?>> entry : labelToSubtype.entrySet()) {
      TypeAdapter<?> delegate = gson.getDelegateAdapter(this, TypeToken.get(entry.getValue()));
      labelToDelegate.put(entry.getKey(), delegate);
      subtypeToDelegate.put(entry.getValue(), delegate);
    }

    return (TypeAdapter<R>) new TypeAdapter<R>() {
     @Override
      public void write(JsonWriter out, R value) throws IOException {
          if (value == null) {
              out.nullValue(); // write JSON null
              return;
          }
            
          Class<?> srcType = value.getClass();
          String label = subtypeToLabel.get(srcType);
          @SuppressWarnings("unchecked")
          TypeAdapter<R> delegate = (TypeAdapter<R>) subtypeToDelegate.get(srcType);
          
          // Convert value to JsonObject
          JsonObject jsonObj = delegate.toJsonTree(value).getAsJsonObject();
          
          // Add type field
          jsonObj.addProperty(typeFieldName, label);
          
          // Write JSON object using Gson's public API
          gson.toJson(jsonObj, out);
      }
      
      @Override
      public R read(JsonReader in) throws IOException {
          // Read JsonObject using Gson's public API
          JsonObject jsonObj = gson.fromJson(in, JsonObject.class);
          JsonElement labelElem = jsonObj.remove(typeFieldName);
          if (labelElem == null) {
              throw new JsonParseException("Missing type field '" + typeFieldName + "'");
          }
          String label = labelElem.getAsString();
          
          @SuppressWarnings("unchecked")
          TypeAdapter<R> delegate = (TypeAdapter<R>) labelToDelegate.get(label);
          if (delegate == null) {
              throw new JsonParseException("Unknown label: " + label);
          }
          return delegate.fromJsonTree(jsonObj);
      }

    };
  }
}
