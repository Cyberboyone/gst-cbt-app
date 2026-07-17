import json
import os

courses = {
    'jamb_eng': 'JAMB Use of English',
    'jamb_phy': 'JAMB Physics',
    'jamb_mth': 'JAMB Mathematics',
    'waec_eng': 'WAEC English Language',
    'waec_mth': 'WAEC Mathematics',
    'cos101': 'Intro to Computer Science',
    'bio101': 'General Biology'
}

base_dir = r'c:\Users\bayum\Desktop\cbt app\assets\questions'

for course_id, course_name in courses.items():
    questions = []
    for i in range(1, 25):
        q = {
            "id": f"{course_id}_{i:03d}",
            "text": f"This is a sample question {i} for {course_name}. What is the correct answer?",
            "options": ["Option A", "Option B", "Option C", "Option D"],
            "correct_index": 0,
            "explanation": f"Option A is correct because this is a sample explanation for {course_name} question {i}.",
            "difficulty": (i % 3) + 1
        }
        questions.append(q)
        
    data = {
        "courseId": course_id,
        "courseName": course_name,
        "questions": questions
    }
    
    file_path = os.path.join(base_dir, f'{course_id}.json')
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2)
        
print("Generated questions for:", list(courses.keys()))
