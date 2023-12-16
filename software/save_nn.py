import tensorflow as tf

# Create a model
model = tf.keras.models.Sequential([
  tf.keras.layers.Dense(128, activation='relu'),
  tf.keras.layers.Dense(64, activation='relu'),
  tf.keras.layers.Dense(10, activation='softmax')
])

# Compile the model
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# Train the model
model.fit(x_train, y_train, epochs=10)

# Save the model's weights to CSV
model.save_weights('my_model_weights.csv')

# Save the model's architecture to CSV
with open('my_model_architecture.json', 'w') as f:
  f.write(model.to_json())